import CloudKit
import Combine

public final class CloudKitItemsRepository: ItemsRepository {
    public var events: AnyPublisher<ItemsEvent, Never> {
        eventsSubject.receive(on: DispatchQueue.main).eraseToAnyPublisher()
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

        operation.modifyRecordsCompletionBlock = { [weak self] records, _, error in
            guard
                let record = records?.first, let
                list = self?.mapper.map(record).toItem()
            else { return }

            self?.eventsSubject.send(.added(list))
        }

        database.add(operation)
    }

    public func update(_ item: Item) {
        guard let recordId = mapper.map(item).toRecordIdInZone(zone) else { return }

        database.fetch(withRecordID: recordId) { [weak self] record, _ in
            self?.mapper.map(record).updatedBy(item).toRecord().map {
                self?.database.save($0) { updatedRecord, _ in
                    if let updatedItem = self?.mapper.map(updatedRecord).toItem(), updatedItem.id == item.id {
                        self?.eventsSubject.send(.updated(updatedItem))
                    } else {
                        self?.eventsSubject.send(.finishedWithoutResult)
                    }
                }
            }
        }
    }

    public func remove(_ item: Item) {
        guard let recordId = mapper.map(item).toRecordIdInZone(zone) else { return }

        let operation = CKModifyRecordsOperation(
            recordsToSave: nil,
            recordIDsToDelete: [recordId]
        )

        operation.modifyRecordsCompletionBlock = { [weak self] _, recordIds, _ in
            let id = recordIds?.first.flatMap { UUID(uuidString: $0.recordName) }
            guard id == item.id.asUuid else { return }
            self?.eventsSubject.send(.removed(item))
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

        operation.modifyRecordsCompletionBlock = { [weak self] _, recordIds, _ in
            let ids: [Id<Item>] = recordIds.map { $0.compactMap { .fromString($0.recordName) } } ?? []
            let removedItems = ids.compactMap { id in items.first { $0.id == id } }

            guard !removedItems.isEmpty else { return }
            self?.eventsSubject.send(.removed(removedItems))
        }

        database.add(operation)
    }
}
