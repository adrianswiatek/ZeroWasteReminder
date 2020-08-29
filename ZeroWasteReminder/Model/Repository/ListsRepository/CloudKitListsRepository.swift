import Combine
import CloudKit

public final class CloudKitListsRepository: ListsRepository {
    public var events: AnyPublisher<ListsEvent, Never> {
        eventsSubject.receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }

    private let eventsSubject: PassthroughSubject<ListsEvent, Never>

    private let database: CKDatabase
    private let zone: CKRecordZone
    private let mapper: CloudKitMapper

    public init(configuration: CloudKitConfiguration, mapper: CloudKitMapper) {
        self.database = configuration.container.database(with: .private)
        self.zone = configuration.appZone
        self.mapper = mapper
        self.eventsSubject = .init()
    }

    public func fetchAll() {
        let query = CKQuery(recordType: "List", predicate: .init(value: true))
        let operation = CKQueryOperation(query: query)

        var records = [CKRecord]()

        operation.recordFetchedBlock = {
            records.append($0)
        }

        operation.completionBlock = { [weak self] in
            let lists = records.compactMap { self?.mapper.map($0).toList() }
            self?.eventsSubject.send(.fetched(lists))
        }

        operation.queryCompletionBlock = { [weak self] in
            $1.map { self?.eventsSubject.send(.error(.init($0))) }
        }

        database.add(operation)
    }

    public func add(_ list: List) {
        guard let record = mapper.map(list).toRecordInZone(zone) else { return }

        let operation = CKModifyRecordsOperation(
            recordsToSave: [record],
            recordIDsToDelete: nil
        )

        operation.modifyRecordsCompletionBlock = { [weak self] in
            if let error = $2 {
                self?.eventsSubject.send(.error(.init(error)))
            } else if let list = self?.mapper.map($0?.first).toList() {
                self?.eventsSubject.send(.added(list))
            }
        }

        database.add(operation)
    }

    public func remove(_ list: List) {
        guard let recordId = mapper.map(list).toRecordIdInZone(zone) else { return }

        let operation = CKModifyRecordsOperation(
            recordsToSave: nil,
            recordIDsToDelete: [recordId]
        )

        operation.modifyRecordsCompletionBlock = { [weak self] in
            let id: Id<List>? = $1?.first.map { .fromString($0.recordName) }
            if let error = $2 {
                self?.eventsSubject.send(.error(.init(error)))
            } else if id == list.id {
                self?.eventsSubject.send(.removed(list))
            }
        }

        database.add(operation)
    }

    public func update(_ list: List) {
        guard let recordId = mapper.map(list).toRecordIdInZone(zone) else { return }

        database.fetch(withRecordID: recordId) { [weak self] in
            if let error = $1 {
                self?.eventsSubject.send(.error(.init(error)))
            } else if let updatedRecord = self?.mapper.map($0).updatedBy(list).toRecord() {
                self?.saveUpdatedRecord(updatedRecord)
            }
        }
    }

    public func update(_ lists: [List]) {
        lists.forEach { update($0) }
    }

    private func saveUpdatedRecord(_ record: CKRecord) {
        database.save(record) { [weak self] in
            if let error = $1 {
                self?.eventsSubject.send(.error(.init(error)))
            } else if let updatedList = self?.mapper.map($0).toList() {
                self?.eventsSubject.send(.updated(updatedList))
            }
        }
    }
}
