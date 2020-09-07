import CloudKit
import Combine

public final class CloudKitItemsRepository: ItemsRepository {
    private let database: CKDatabase
    private let zone: CKRecordZone
    private let cache: CloudKitCache
    private let mapper: CloudKitMapper
    private let eventBus: EventBus

    private var subscriptions: [String: AnyCancellable]

    public init(
        configuration: CloudKitConfiguration,
        cache: CloudKitCache,
        mapper: CloudKitMapper,
        eventBus: EventBus
    ) {
        self.database = configuration.container.database(with: .private)
        self.zone = configuration.appZone
        self.cache = cache
        self.mapper = mapper
        self.eventBus = eventBus
        self.subscriptions = [:]
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
            self?.cache.invalidate()
            self?.cache.set(records)

            let items = records.compactMap { self?.mapper.map($0).toItem() }
            self?.eventBus.send(ItemsFetchedEvent(items))
        }

        operation.queryCompletionBlock = { [weak self] in
            $1.map { self?.eventBus.send(ErrorEvent(.init($0))) }
        }

        database.add(operation)
    }

    public func add(_ itemToSave: ItemToSave) {
        guard
            let listRecord = mapper.map(itemToSave.list).toRecordInZone(zone),
            let itemRecord = mapper.map(itemToSave.item).toRecordInZone(zone, referencedBy: listRecord)
        else { return }

        let operation = CKModifyRecordsOperation(recordsToSave: [itemRecord], recordIDsToDelete: nil)
        operation.modifyRecordsCompletionBlock = { [weak self] in
            if let error = $2 {
                self?.eventBus.send(ErrorEvent(.init(error)))
            } else if let item = self?.mapper.map($0?.first).toItem() {
                $0?.first.map { self?.cache.set($0) }
                self?.eventBus.send(ItemAddedEvent(item))
            } else {
                self?.eventBus.send(EmptyEvent())
            }
        }

        database.add(operation)
    }

    public func update(_ item: Item) {
        subscriptions["update"] = internalUpdate(item)
            .sink(
                receiveCompletion: { [weak self] _ in self?.subscriptions.removeValue(forKey: "update") },
                receiveValue: { [weak self] in self?.eventBus.send($0) }
            )
    }

    public func move(_ item: Item, to list: List) {
        subscriptions["move"] = internalUpdate(item.withListId(list.id))
            .sink(
                receiveCompletion: { [weak self] _ in
                    self?.subscriptions.removeValue(forKey: "move")
                },
                receiveValue: { [weak self] in
                    if let event = $0 as? ItemUpdatedEvent {
                        self?.eventBus.send(ItemMovedEvent(event.item, to: list))
                    } else {
                        self?.eventBus.send($0)
                    }
                }
            )
    }

    public func remove(_ item: Item) {
        guard let recordId = mapper.map(item).toRecordIdInZone(zone) else { return }

        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [recordId])
        operation.modifyRecordsCompletionBlock = { [weak self] in
            let id: Id<Item>? = $1?.first.map { .fromString($0.recordName) }
            if let error = $2 {
                self?.eventBus.send(ErrorEvent(.init(error)))
            } else if id == item.id {
                $1?.first.map { self?.cache.removeById($0) }
                self?.eventBus.send(ItemsRemovedEvent(item))
            } else {
                self?.eventBus.send(EmptyEvent())
            }
        }

        database.add(operation)
    }

    public func remove(_ items: [Item]) {
        let recordIds = items.compactMap { mapper.map($0).toRecordIdInZone(zone) }
        guard !recordIds.isEmpty else { return }

        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: recordIds)
        operation.modifyRecordsCompletionBlock = { [weak self] in
            let ids: [Id<Item>] = $1.map { $0.compactMap { .fromString($0.recordName) } } ?? []
            let removedItems = ids.compactMap { id in items.first { $0.id == id } }

            if let error = $2 {
                self?.eventBus.send(ErrorEvent(.init(error)))
            } else if !removedItems.isEmpty {
                $1.map { self?.cache.removeByIds($0) }
                self?.eventBus.send(ItemsRemovedEvent(removedItems))
            } else {
                self?.eventBus.send(EmptyEvent())
            }
        }

        database.add(operation)
    }

    private func internalUpdate(_ item: Item) -> Future<AppEvent, Never> {
        Future { [weak self] promise in
            guard let self = self, let recordId = self.mapper.map(item).toRecordIdInZone(self.zone) else {
                return promise(.success(EmptyEvent()))
            }

            self.subscriptions["internalUpdate"] = self.fetchRecords(with: recordId)
                .flatMap { [weak self] record -> AnyPublisher<CKRecord?, Error> in
                    guard let self = self, let record = record else { return Empty().eraseToAnyPublisher() }
                    return self.update(record, by: item).eraseToAnyPublisher()
                }
                .sink(
                    receiveCompletion: { [weak self] in
                        if case .failure(let error) = $0 {
                            promise(.success(ErrorEvent(.init(error))))
                        }
                        self?.subscriptions.removeValue(forKey: "internalUpdate")
                    },
                    receiveValue: { [weak self] in
                        if let record = $0, let updatedItem = self?.mapper.map(record).toItem() {
                            self?.cache.set(record)
                            promise(.success(ItemUpdatedEvent(updatedItem)))
                        } else {
                            promise(.success(EmptyEvent()))
                        }
                    }
                )
        }
    }

    private func fetchRecords(with id: CKRecord.ID) -> Future<CKRecord?, Error> {
        Future { [weak self] promise in
            if let record = self?.cache.findById(id) {
                return promise(.success(record))
            }

            let query = CKQuery(recordType: "Item", predicate: .init(format: "%K == %@", "recordID", id))
            let operation = CKQueryOperation(query: query)

            var record: CKRecord?
            var error: Error?

            operation.recordFetchedBlock = { record = $0 }
            operation.queryCompletionBlock = { error = $1 }

            operation.completionBlock = {
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(record))
                }
            }

            self?.database.add(operation)
        }
    }

    private func update(_ record: CKRecord, by item: Item) -> Future<CKRecord?, Error> {
        Future { [weak self] promise in
            guard let updatedRecord = self?.mapper.map(record).updatedBy(item).toRecord() else {
                return promise(.success(nil))
            }

            let operation = CKModifyRecordsOperation(recordsToSave: [updatedRecord])
            operation.savePolicy = .changedKeys

            var record: CKRecord?
            var error: Error?

            operation.perRecordCompletionBlock = {
                record = $0
                error = $1
            }

            operation.completionBlock = {
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(record))
                }
            }

            self?.database.add(operation)
        }
    }
}
