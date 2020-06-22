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
            guard let self = self, photosChangeset.hasChanges else {
                return promise(.success(()))
            }

            let operation = CKModifyRecordsOperation(
                recordsToSave: self.mapToRecords(photosChangeset.photosToSave, forItem: item),
                recordIDsToDelete: self.mapToRecordIds(photosChangeset.idsToDelete)
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

    private func mapToRecords(_ photos: [PhotoToSave], forItem item: Item) -> [CKRecord] {
        let itemRecord = mapper.map(item).toRecordInZone(zone)
        return photos.compactMap { mapper.map($0).toRecordInZone(zone, referencedBy: itemRecord) }
    }

    private func mapToRecordIds(_ ids: [UUID]) -> [CKRecord.ID] {
        ids.compactMap { .init(recordName: $0.uuidString, zoneID: zone.zoneID) }
    }
}