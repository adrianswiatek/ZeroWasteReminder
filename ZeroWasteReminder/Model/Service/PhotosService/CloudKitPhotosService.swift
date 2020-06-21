import CloudKit
import Combine
import Foundation

public final class CloudKitPhotosService: PhotosService {
    private var database: CKDatabase {
        configuration.container.database(with: .private)
    }

    private var zone: CKRecordZone {
        configuration.itemsZone
    }

    private let configuration: CloudKitConfiguration
    private let itemsRepository: ItemsRepository
    private let mapper: CloudKitMapper

    public init(
        configuration: CloudKitConfiguration,
        itemsRepository: ItemsRepository,
        mapper: CloudKitMapper
    ) {
        self.configuration = configuration
        self.itemsRepository = itemsRepository
        self.mapper = mapper
    }

    public func fetchThumbnails(forItem item: Item) -> Future<[Photo], ServiceError> {
        Future { [weak self] promise in
            guard let self = self else { return }
            var photoRecords = [CKRecord]()

            let itemReference = CKRecord.Reference(
                recordID: .init(recordName: item.id.uuidString, zoneID: self.zone.zoneID),
                action: .none
            )

            let predicate = NSPredicate(format: "%K == %@", CloudKitKey.Photo.itemReference, itemReference)

            let operation = CKQueryOperation(query: .init(recordType: "Photo", predicate: predicate))
            operation.desiredKeys = [CloudKitKey.Photo.thumbnail]

            operation.recordFetchedBlock = { photoRecords.append($0) }
            operation.queryCompletionBlock = {
                if let error = $1 {
                    DispatchQueue.main.async { promise(.failure(ServiceError(error))) }
                } else {
                    let photos = photoRecords.compactMap { self.mapper.map($0).toThumbnail() }
                    DispatchQueue.main.async { promise(.success(photos)) }
                }
            }

            self.database.add(operation)
        }
    }

    public func fetchFullSize(withId photoId: UUID) -> Future<Photo, ServiceError> {
        Future { [weak self] promise in
            guard let self = self else { return }

            var resultRecord: CKRecord?

            let recordId = CKRecord.ID(recordName: photoId.uuidString, zoneID: self.zone.zoneID)
            let predicate = NSPredicate(format: "%K == %@", "recordID", recordId)

            let operation = CKQueryOperation(query: .init(recordType: "Photo", predicate: predicate))
            operation.desiredKeys = [CloudKitKey.Photo.fullSize]

            operation.recordFetchedBlock = { resultRecord = $0 }
            operation.queryCompletionBlock = {
                if let error = $1 {
                    DispatchQueue.main.async { promise(.failure(ServiceError(error))) }
                } else {
                    let fullSize: Photo! = resultRecord.flatMap { self.mapper.map($0).toFullSize() }
                    DispatchQueue.main.async { promise(.success(fullSize)) }
                }
            }

            self.database.add(operation)
        }
    }

    public func update(
        _ photosChangeset: PhotosChangeset,
        forItem item: Item
    ) -> Future<Void, ServiceError> {
        Future { [weak self] promise in
            guard let self = self else { return }

            let itemRecord = self.mapper.map(item).toRecordInZone(self.zone)
            let photoRecordsToSave = photosChangeset.photosToSave.compactMap {
                self.mapper.map($0).toRecordInZone(self.zone, referencedBy: itemRecord)
            }

            let photosRecordsToDelete = photosChangeset.idsToDelete.compactMap {
                CKRecord.ID(recordName: $0.uuidString, zoneID: self.zone.zoneID)
            }

            guard !photoRecordsToSave.isEmpty || !photosRecordsToDelete.isEmpty else {
                promise(.success(()))
                return
            }

            let operation = CKModifyRecordsOperation(
                recordsToSave: photoRecordsToSave,
                recordIDsToDelete: photosRecordsToDelete
            )

            operation.modifyRecordsCompletionBlock = {
                if let error = $2 {
                    DispatchQueue.main.async { promise(.failure(ServiceError(error))) }
                } else {
                    DispatchQueue.main.async { promise(.success(())) }
                }
            }

            self.database.add(operation)
        }
    }
}
