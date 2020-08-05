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

//public final class CloudKitItemsService {
//    private var database: CKDatabase {
//        configuration.container.database(with: .private)
//    }
//
//    private var zone: CKRecordZone {
//        configuration.itemsZone
//    }
//
//    private let configuration: CloudKitConfiguration
//    private let itemsRepository: ItemsRepository
//    private let mapper: CloudKitMapper
//    private let notificationCenter: NotificationCenter
//
//    private var cachedItemRecords: Set<CKRecord>
//    private var subscriptions: Set<AnyCancellable>
//
//    public init(
//        configuration: CloudKitConfiguration,
//        itemsRepository: ItemsRepository,
//        mapper: CloudKitMapper,
//        notificationCenter: NotificationCenter
//    ) {
//        self.configuration = configuration
//        self.itemsRepository = itemsRepository
//        self.mapper = mapper
//        self.notificationCenter = notificationCenter
//
//        self.cachedItemRecords = []
//        self.subscriptions = []
//
//        self.registerNotification()
//    }
//
//    public func add(_ item: Item) -> Future<Void, ServiceError> {
//        Future { [weak self] promise in
//            guard let self = self, let itemRecord = self.mapper.map(item).toRecordInZone(self.zone) else {
//                return
//            }
//
//            let operation = CKModifyRecordsOperation(recordsToSave: [itemRecord])
//            operation.modifyRecordsCompletionBlock = { records, _, error in
//                if let error = error {
//                    DispatchQueue.main.async { promise(.failure(.init(error))) }
//                } else if let record = records?.first, let item = self.mapper.map(record).toItem() {
//                    self.itemsRepository.add(item)
//                    self.cachedItemRecords.insert(record)
//                    DispatchQueue.main.async { promise(.success(())) }
//                }
//            }
//
//            self.database.add(operation)
//        }
//    }
//
//    public func refresh() -> Future<Void, ServiceError> {
//        Future { [weak self] promise in
//            var result = [CKRecord]()
//
//            let operation = CKQueryOperation(query: .init(recordType: "Item", predicate: .init(value: true)))
//            operation.recordFetchedBlock = { result.append($0) }
//            operation.queryCompletionBlock = { _, error in
//                if let error = error {
//                    DispatchQueue.main.async { promise(.failure(ServiceError(error))) }
//                } else {
//                    self?.itemsRepository.set(result.compactMap { self?.mapper.map($0).toItem() })
//                    self?.cachedItemRecords = Set(result)
//                    DispatchQueue.main.async { promise(.success(())) }
//                }
//            }
//
//            self?.database.add(operation)
//        }
//    }
//
//    public func update(_ item: Item) -> Future<Void, ServiceError> {
//        Future { [weak self] promise in
//            guard let self = self, let record = self.recordToUpdate(from: item) else { return }
//
//            let updateOperation = self.updateOperation(for: record, promise: promise)
//            let fetchOperation = self.postUpdatingFetchOperation(for: item, promise: promise)
//            fetchOperation.addDependency(updateOperation)
//
//            self.database.add(updateOperation)
//            self.database.add(fetchOperation)
//        }
//    }
//
//    public func delete(_ items: [Item]) -> Future<Void, ServiceError> {
//        deleteItems(items)
//    }
//
//    public func deleteAll() -> Future<Void, ServiceError> {
//        deleteItems(itemsRepository.allItems())
//    }
//
//    private func deleteItems(_ items: [Item]) -> Future<Void, ServiceError> {
//        Future { [weak self] promise in
//            guard let self = self else { return }
//
//            let recordIds = items.compactMap { self.mapper.map($0).toRecordInZone(self.zone)?.recordID }
//            let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: recordIds)
//            operation.modifyRecordsCompletionBlock = { _, deletedRecordIds, error in
//                if let error = error {
//                    DispatchQueue.main.async { promise(.failure(ServiceError(error))) }
//                } else if let deletedRecordIds = deletedRecordIds {
//                    let deletedItemIds = deletedRecordIds.compactMap { UUID(uuidString: $0.recordName) }
//                    self.itemsRepository.delete(deletedItemIds)
//                    self.cachedItemRecords = self.cachedItemRecords.filter { !deletedRecordIds.contains($0.recordID) }
//                }
//                DispatchQueue.main.async { promise(.success(())) }
//            }
//
//            self.database.add(operation)
//        }
//    }
//
//    private func recordToUpdate(from item: Item) -> CKRecord? {
//        let recordId = mapper.map(item).toRecordIdInZone(zone)
//        let cachedRecord = cachedItemRecords.first { $0.recordID == recordId }
//        return mapper.map(cachedRecord).updatedBy(item).toRecord()
//    }
//
//    private func updateOperation(
//        for record: CKRecord,
//        promise: @escaping (Result<Void, ServiceError>) -> Void
//    ) -> CKModifyRecordsOperation {
//        let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
//        operation.savePolicy = .changedKeys
//        operation.modifyRecordsCompletionBlock = { _, _, error in
//            guard let error = error as? CKError else { return }
//            DispatchQueue.main.async { promise(.failure(ServiceError.general(error.localizedDescription))) }
//        }
//        return operation
//    }
//
//    private func postUpdatingFetchOperation(
//        for item: Item,
//        promise: @escaping (Result<Void, ServiceError>) -> Void
//    ) -> CKQueryOperation {
//        let recordId = CKRecord.ID(recordName: item.id.uuidString, zoneID: zone.zoneID)
//        let predicate = NSPredicate(format: "%K == %@", "recordID", recordId)
//        let operation = CKQueryOperation(query: .init(recordType: "Item", predicate: predicate))
//        operation.recordFetchedBlock = { [weak self] record in
//            guard let item = self?.mapper.map(record).toItem() else { return }
//
//            if let cachedRecordToDelete = self?.cachedItemRecords.first(where: { $0.recordID == record.recordID }) {
//                self?.cachedItemRecords.remove(cachedRecordToDelete)
//            }
//
//            self?.cachedItemRecords.insert(record)
//            self?.itemsRepository.update(item)
//        }
//        operation.queryCompletionBlock = { _, error in
//            if let error = error as? CKError {
//                DispatchQueue.main.async { promise(.failure(ServiceError.general(error.localizedDescription))) }
//            } else {
//                DispatchQueue.main.async { promise(.success(())) }
//            }
//        }
//        return operation
//    }
//
//    private func registerNotification() {
//        notificationCenter.publisher(for: .itemUpdateReceived)
//            .sink { [weak self] _ in _ = self?.refresh() }
//            .store(in: &subscriptions)
//    }
//}
