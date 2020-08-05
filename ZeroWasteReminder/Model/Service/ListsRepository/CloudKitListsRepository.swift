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

        database.add(operation)
    }

    public func add(_ list: List) {
        guard let record = mapper.map(list).toRecordInZone(zone) else { return }

        let operation = CKModifyRecordsOperation(
            recordsToSave: [record],
            recordIDsToDelete: nil
        )

        operation.modifyRecordsCompletionBlock = { [weak self] records, _, error in
            guard
                let record = records?.first, let
                list = self?.mapper.map(record).toList()
            else { return }

            self?.eventsSubject.send(.added(list))
        }

        database.add(operation)
    }

    public func remove(_ list: List) {
        guard let recordId = mapper.map(list).toRecordIdInZone(zone) else { return }

        let operation = CKModifyRecordsOperation(
            recordsToSave: nil,
            recordIDsToDelete: [recordId]
        )

        operation.modifyRecordsCompletionBlock = { [weak self] _, recordIds, error in
            let id: Id<List>? = recordIds?.first.map { .fromString($0.recordName) }
            guard id == list.id else { return }
            self?.eventsSubject.send(.removed(list))
        }

        database.add(operation)
    }

    public func update(_ list: List) {
        guard let record = mapper.map(list).toRecordInZone(zone) else { return }

        let operation = CKModifyRecordsOperation(
            recordsToSave: [record],
            recordIDsToDelete: nil
        )
        operation.savePolicy = .allKeys
        operation.modifyRecordsCompletionBlock = { [weak self] records, _, error in
            records?.first
                .flatMap { self?.mapper.map($0).toList() }
                .map { self?.eventsSubject.send(.updated($0)) }
        }

        database.add(operation)
    }
}
