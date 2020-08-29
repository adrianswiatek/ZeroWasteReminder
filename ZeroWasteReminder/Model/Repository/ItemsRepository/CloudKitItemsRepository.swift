import CloudKit
import Combine

public final class CloudKitItemsRepository: ItemsRepository {
    public var events: AnyPublisher<ItemsEvent, Never> {
        eventsSubject.receive(on: DispatchQueue.main).share().eraseToAnyPublisher()
    }

    private let eventsSubject: PassthroughSubject<ItemsEvent, Never>

    private let database: CKDatabase
    private let zone: CKRecordZone
    private let mapper: CloudKitMapper

    public init(configuration: CloudKitConfiguration, mapper: CloudKitMapper) {
        self.database = configuration.container.database(with: .private)
        self.zone = configuration.appZone
        self.mapper = mapper
        self.eventsSubject = .init()
    }

    public func fetchAll(from list: List) {
        let recordId = CKRecord.ID(recordName: list.id.asString, zoneID: zone.zoneID)
        let listReference = CKRecord.Reference(recordID: recordId, action: .none)
        let predicate = NSPredicate(format: "%K = %@", CloudKitKey.Item.listReference, listReference)
        let query = CKQuery(recordType: "Item", predicate: predicate)
        let operation = CKQueryOperation(query: query)

        var records = [CKRecord]()

        operation.recordFetchedBlock = {
            records.append($0)
        }

        operation.completionBlock = { [weak self] in
            let items = records.compactMap { self?.mapper.map($0).toItem() }
            self?.eventsSubject.send(.fetched(items))
        }

        operation.queryCompletionBlock = { [weak self] in
            $1.map { self?.eventsSubject.send(.error(.init($0))) }
        }

        database.add(operation)
    }

    public func add(_ itemToSave: ItemToSave) {
        guard
            let listRecord = mapper.map(itemToSave.list).toRecordInZone(zone),
            let itemRecord = mapper.map(itemToSave.item).toRecordInZone(zone, referencedBy: listRecord)
        else { return }

        let operation = CKModifyRecordsOperation(
            recordsToSave: [itemRecord],
            recordIDsToDelete: nil
        )

        operation.modifyRecordsCompletionBlock = { [weak self] in
            if let error = $2 {
                self?.eventsSubject.send(.error(.init(error)))
            } else if let item = self?.mapper.map($0?.first).toItem() {
                self?.eventsSubject.send(.added(item))
            }
        }

        database.add(operation)
    }

    public func remove(_ item: Item) {
        guard let recordId = mapper.map(item).toRecordIdInZone(zone) else { return }

        let operation = CKModifyRecordsOperation(
            recordsToSave: nil,
            recordIDsToDelete: [recordId]
        )

        operation.modifyRecordsCompletionBlock = { [weak self] in
            let id: Id<Item>? = $1?.first.map { .fromString($0.recordName) }
            if let error = $2 {
                self?.eventsSubject.send(.error(.init(error)))
            } else if id == item.id {
                self?.eventsSubject.send(.removed(item))
            }
        }

        database.add(operation)
    }

    public func remove(_ items: [Item]) {
        let recordIds = items.compactMap { mapper.map($0).toRecordIdInZone(zone) }
        guard !recordIds.isEmpty else { return }

        let operation = CKModifyRecordsOperation(
            recordsToSave: nil,
            recordIDsToDelete: recordIds
        )

        operation.modifyRecordsCompletionBlock = { [weak self] in
            let ids: [Id<Item>] = $1.map { $0.compactMap { .fromString($0.recordName) } } ?? []
            let removedItems = ids.compactMap { id in items.first { $0.id == id } }

            if let error = $2 {
                self?.eventsSubject.send(.error(.init(error)))
            } else if !removedItems.isEmpty {
                self?.eventsSubject.send(.removed(removedItems))
            }
        }

        database.add(operation)
    }

    public func update(_ item: Item) {
        guard let recordId = mapper.map(item).toRecordIdInZone(zone) else { return }

        database.fetch(withRecordID: recordId) { [weak self] in
            if let error = $1 {
                self?.eventsSubject.send(.error(.init(error)))
            } else if let updatedRecord = self?.mapper.map($0).updatedBy(item).toRecord() {
                self?.saveUpdatedRecord(updatedRecord)
            }
        }
    }

    private func saveUpdatedRecord(_ record: CKRecord) {
        database.save(record) { [weak self] in
            if let error = $1 {
                self?.eventsSubject.send(.error(.init(error)))
            } else if let updatedItem = self?.mapper.map($0).toItem() {
                self?.eventsSubject.send(.updated(updatedItem))
            }
        }
    }
}
