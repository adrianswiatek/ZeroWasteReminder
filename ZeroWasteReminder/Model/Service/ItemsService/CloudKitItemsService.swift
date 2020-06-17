import CloudKit
import Combine

public final class CloudKitItemsService: ItemsService {
    public var items: AnyPublisher<[Item], Never> {
        itemsSubject.receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }

    private var database: CKDatabase {
        configuration.container.database(with: .private)
    }

    private var zone: CKRecordZone {
        configuration.itemsZone
    }

    private let itemsSubject: CurrentValueSubject<[Item], Never>
    private let mapper: CloudKitMapper
    private let notificationCenter: NotificationCenter
    private let configuration: CloudKitConfiguration

    private var cachedItemRecords: Set<CKRecord>
    private var subscriptions: Set<AnyCancellable>

    public init(
        configuration: CloudKitConfiguration,
        mapper: CloudKitMapper,
        notificationCenter: NotificationCenter
    ) {
        self.configuration = configuration
        self.mapper = mapper
        self.notificationCenter = notificationCenter

        self.itemsSubject = .init([])

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
                    self.itemsSubject.value = self.itemsSubject.value + [item]
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
            operation.queryCompletionBlock = {
                if let error = $1 {
                    DispatchQueue.main.async { promise(.failure(ServiceError(error))) }
                } else {
                    self?.itemsSubject.value = result.compactMap { self?.mapper.map($0).toItem() }
                    self?.cachedItemRecords = Set(result)
                    DispatchQueue.main.async { promise(.success(())) }
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

    public func updatePhotos(_ photosChangeset: PhotosChangeset, forItem item: Item) -> Future<Void, ServiceError> {
        Future { [weak self] promise in
            guard let self = self else { return }

            let itemRecord = self.mapper.map(item).toRecordInZone(self.zone)
            let photoRecordsToSave = photosChangeset.toSave.compactMap {
                self.mapper.map($0).toRecordInZone(self.zone, referencedBy: itemRecord)
            }

            let photosRecordsToDelete = photosChangeset.toDelete.compactMap {
                self.mapper.map($0).toRecordInZone(self.zone)?.recordID
            }

            guard !photoRecordsToSave.isEmpty || !photosRecordsToDelete.isEmpty else {
                promise(.success(()))
                return
            }

            let operation = CKModifyRecordsOperation(
                recordsToSave: photoRecordsToSave,
                recordIDsToDelete: photosRecordsToDelete
            )

            operation.modifyRecordsCompletionBlock = { insertedRecords, deletedRecordIds, error in
                if let error = error {
                    DispatchQueue.main.async { promise(.failure(ServiceError(error))) }
                } else {
                    self.modifyPhotosCompleted(forItem: item, insertedRecords ?? [], deletedRecordIds ?? [])
                    DispatchQueue.main.async { promise(.success(())) }
                }
            }

            self.database.add(operation)
        }
    }

    public func delete(_ items: [Item]) -> Future<Void, ServiceError> {
        deleteItems(items)
    }

    public func deleteAll() -> Future<Void, ServiceError> {
        deleteItems(itemsSubject.value)
    }

    public func fetchPhotos(forItem item: Item) -> Future<[Photo], ServiceError> {
        Future { [weak self] promise in
            guard let self = self else { return }
            var photoRecords = [CKRecord]()

            let itemReference = CKRecord.Reference(
                recordID: .init(recordName: item.id.uuidString, zoneID: self.zone.zoneID),
                action: .none
            )

            let predicate = NSPredicate(format: "%K == %@", CloudKitKey.Photo.itemReference, itemReference)
            let operation = CKQueryOperation(query: .init(recordType: "Photo", predicate: predicate))
            operation.recordFetchedBlock = { photoRecords.append($0) }
            operation.queryCompletionBlock = {
                if let error = $1 {
                    DispatchQueue.main.async { promise(.failure(ServiceError(error))) }
                } else {
                    let photos = photoRecords.compactMap { self.mapper.map($0).toPhoto() }
                    DispatchQueue.main.async { promise(.success(photos)) }
                }
            }

            self.database.add(operation)
        }
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
                    self.itemsSubject.value = self.itemsSubject.value.filter { !deletedItemIds.contains($0.id) }
                    self.cachedItemRecords = self.cachedItemRecords.filter { !deletedRecordIds.contains($0.recordID) }
                }
                DispatchQueue.main.async { promise(.success(())) }
            }

            self.database.add(operation)
        }
    }

    private func modifyPhotosCompleted(
        forItem item: Item,
        _ insertedRecords: [CKRecord],
        _ deletedRecordIds: [CKRecord.ID]
    ) {
        guard let itemIndex = itemsSubject.value.firstIndex(where: { $0.id == item.id }) else { return }

        var photos = itemsSubject.value[itemIndex].photos

        insertedRecords
            .compactMap { mapper.map($0).toPhoto() }
            .forEach { photo in photos.insert(photo, at: 0) }

        deletedRecordIds
            .compactMap { UUID(uuidString: $0.recordName) }
            .forEach { photoId in photos.removeAll { $0.id == photoId } }

        itemsSubject.value[itemIndex] = Item(
            id: item.id,
            name: item.name,
            notes: item.notes,
            expiration: item.expiration,
            photos: item.photos
        )
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
            guard let index = self?.indexForItem(item), let item = self?.mapper.map(record).toItem() else {
                return
            }

            if let cachedRecordToDelete = self?.cachedItemRecords.first(where: { $0.recordID == record.recordID }) {
                self?.cachedItemRecords.remove(cachedRecordToDelete)
            }

            self?.cachedItemRecords.insert(record)
            self?.itemsSubject.value[index] = item
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

    private func indexForItem(_ item: Item) -> Int? {
        itemsSubject.value.firstIndex { $0.id == item.id }
    }

    private func registerNotification() {
        notificationCenter.publisher(for: .itemUpdateReceived)
            .sink { [weak self] _ in _ = self?.refresh() }
            .store(in: &subscriptions)
    }
}
