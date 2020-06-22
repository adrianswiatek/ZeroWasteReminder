import CloudKit
import Combine

public final class CloudKitItemsService: ItemsService {
    private var database: CKDatabase {
        configuration.container.database(with: .private)
    }

    private var zone: CKRecordZone {
        configuration.itemsZone
    }

    private let configuration: CloudKitConfiguration
    private let itemsRepository: ItemsRepository
    private let mapper: CloudKitMapper
    private let notificationCenter: NotificationCenter

    private var cachedItemRecords: Set<CKRecord>
    private var subscriptions: Set<AnyCancellable>

    public init(
        configuration: CloudKitConfiguration,
        itemsRepository: ItemsRepository,
        mapper: CloudKitMapper,
        notificationCenter: NotificationCenter
    ) {
        self.configuration = configuration
        self.itemsRepository = itemsRepository
        self.mapper = mapper
        self.notificationCenter = notificationCenter

        self.cachedItemRecords = []
        self.subscriptions = []

        self.registerNotification()
    }

    public func add(_ item: Item) -> Future<Void, ServiceError> {
        Future { [weak self] promise in
            guard let self = self, let itemRecord = self.mapper.map(item).toRecordInZone(self.zone) else {
                return
            }

            let photoRecords = item.photos.compactMap {
                self.mapper.map($0).toRecordInZone(self.zone, referencedBy: itemRecord)
            }

            let operation = CKModifyRecordsOperation(recordsToSave: [itemRecord] + photoRecords)
            operation.modifyRecordsCompletionBlock = { records, _, error in
                if let error = error {
                    DispatchQueue.main.async { promise(.failure(.init(error))) }
                } else if let record = records?.first, let item = self.mapper.map(record).toItem() {
                    self.itemsRepository.add(item)
                    self.cachedItemRecords.insert(record)
                    DispatchQueue.main.async { promise(.success(())) }
                }
            }

            self.database.add(operation)
        }
    }

    public func refresh() -> Future<Void, ServiceError> {
        Future { [weak self] promise in
            var result = [CKRecord]()

            let operation = CKQueryOperation(query: .init(recordType: "Item", predicate: .init(value: true)))
            operation.recordFetchedBlock = { result.append($0) }
            operation.queryCompletionBlock = { _, error in
                DispatchQueue.main.async {
                    if let error = error {
                        promise(.failure(ServiceError(error)))
                    } else {
                        self?.itemsRepository.set(result.compactMap { self?.mapper.map($0).toItem() })
                        self?.cachedItemRecords = Set(result)
                        promise(.success(()))
                    }
                }
            }

            self?.database.add(operation)
        }
    }

    public func update(_ item: Item) -> Future<Void, ServiceError> {
        Future { [weak self] promise in
            guard let self = self, let record = self.recordToUpdate(from: item) else { return }

            let updateOperation = self.updateOperation(for: record, promise: promise)
            let fetchOperation = self.postUpdatingFetchOperation(for: item, promise: promise)
            fetchOperation.addDependency(updateOperation)

            self.database.add(updateOperation)
            self.database.add(fetchOperation)
        }
    }

    public func delete(_ items: [Item]) -> Future<Void, ServiceError> {
        deleteItems(items)
    }

    public func deleteAll() -> Future<Void, ServiceError> {
        deleteItems(itemsRepository.allItems())
    }

    private func deleteItems(_ items: [Item]) -> Future<Void, ServiceError> {
        Future { [weak self] promise in
            guard let self = self else { return }

            let recordIds = items.compactMap { self.mapper.map($0).toRecordInZone(self.zone)?.recordID }
            let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: recordIds)
            operation.modifyRecordsCompletionBlock = { _, deletedRecordIds, error in
                if let error = error {
                    DispatchQueue.main.async { promise(.failure(ServiceError(error))) }
                } else if let deletedRecordIds = deletedRecordIds {
                    let deletedItemIds = deletedRecordIds.compactMap { UUID(uuidString: $0.recordName) }
                    self.itemsRepository.delete(deletedItemIds)
                    self.cachedItemRecords = self.cachedItemRecords.filter { !deletedRecordIds.contains($0.recordID) }
                }
                DispatchQueue.main.async { promise(.success(())) }
            }

            self.database.add(operation)
        }
    }

    private func recordToUpdate(from item: Item) -> CKRecord? {
        let recordId = mapper.map(item).toRecordIdInZone(zone)
        let cachedRecord = cachedItemRecords.first { $0.recordID == recordId }
        return mapper.map(cachedRecord).updatedBy(item).toRecord()
    }

    private func updateOperation(
        for record: CKRecord,
        promise: @escaping (Result<Void, ServiceError>) -> Void
    ) -> CKModifyRecordsOperation {
        let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        operation.savePolicy = .changedKeys
        operation.modifyRecordsCompletionBlock = { _, _, error in
            guard let error = error as? CKError else { return }
            DispatchQueue.main.async { promise(.failure(ServiceError.general(error.localizedDescription))) }
        }
        return operation
    }

    private func postUpdatingFetchOperation(
        for item: Item,
        promise: @escaping (Result<Void, ServiceError>) -> Void
    ) -> CKQueryOperation {
        let recordId = CKRecord.ID(recordName: item.id.uuidString, zoneID: zone.zoneID)
        let predicate = NSPredicate(format: "%K == %@", "recordID", recordId)
        let operation = CKQueryOperation(query: .init(recordType: "Item", predicate: predicate))
        operation.recordFetchedBlock = { [weak self] record in
            guard let item = self?.mapper.map(record).toItem() else { return }

            if let cachedRecordToDelete = self?.cachedItemRecords.first(where: { $0.recordID == record.recordID }) {
                self?.cachedItemRecords.remove(cachedRecordToDelete)
            }

            self?.cachedItemRecords.insert(record)
            self?.itemsRepository.update(item)
        }
        operation.queryCompletionBlock = { _, error in
            if let error = error as? CKError {
                DispatchQueue.main.async { promise(.failure(ServiceError.general(error.localizedDescription))) }
            } else {
                DispatchQueue.main.async { promise(.success(())) }
            }
        }
        return operation
    }

    private func registerNotification() {
        notificationCenter.publisher(for: .itemUpdateReceived)
            .sink { [weak self] _ in _ = self?.refresh() }
            .store(in: &subscriptions)
    }
}
