import CloudKit
import Combine
import Foundation

public final class CloudKitPhotosRepository: PhotosRepository {
    private var database: CKDatabase {
        configuration.container.database(with: .private)
    }

    private var zone: CKRecordZone {
        configuration.appZone
    }

    private let configuration: CloudKitConfiguration
    private let mapper: CloudKitMapper

    public init(configuration: CloudKitConfiguration, mapper: CloudKitMapper) {
        self.configuration = configuration
        self.mapper = mapper
    }

    public func fetchThumbnails(for item: Item) -> Future<[Photo], AppError> {
        Future { [weak self] promise in
            guard let self = self else { return }
            var photoRecords = [CKRecord]()

            let itemReference = CKRecord.Reference(
                recordID: .init(recordName: item.id.asString, zoneID: self.zone.zoneID),
                action: .none
            )

            let predicate = NSPredicate(format: "%K == %@", CloudKitKey.Photo.itemReference, itemReference)

            let operation = CKQueryOperation(query: .init(recordType: "Photo", predicate: predicate))
            operation.desiredKeys = [CloudKitKey.Photo.thumbnail]

            operation.recordFetchedBlock = { photoRecords.append($0) }
            operation.queryCompletionBlock = {
                if let error = $1 {
                    DispatchQueue.main.async { promise(.failure(AppError(error))) }
                } else {
                    let photos = photoRecords.compactMap { self.mapper.map($0).toThumbnail() }
                    DispatchQueue.main.async { promise(.success(photos)) }
                }
            }

            self.database.add(operation)
        }
    }

    public func fetchFullSize(with photoId: Id<Photo>) -> Future<Photo, AppError> {
        Future { [weak self] promise in
            guard let self = self else { return }

            var resultRecord: CKRecord?

            let recordId = CKRecord.ID(recordName: photoId.asString, zoneID: self.zone.zoneID)
            let predicate = NSPredicate(format: "%K == %@", "recordID", recordId)

            let operation = CKQueryOperation(query: .init(recordType: "Photo", predicate: predicate))
            operation.desiredKeys = [CloudKitKey.Photo.fullSize]

            operation.recordFetchedBlock = { resultRecord = $0 }
            operation.queryCompletionBlock = {
                if let error = $1 {
                    DispatchQueue.main.async { promise(.failure(AppError(error))) }
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
        for item: Item
    ) -> Future<Void, Never> {
        Future { [weak self] promise in
            guard let self = self, photosChangeset.hasChanges else {
                return promise(.success(()))
            }

            let operation = CKModifyRecordsOperation(
                recordsToSave: self.mapToRecords(photosChangeset.photosToSave, for: item),
                recordIDsToDelete: self.mapToRecordIds(photosChangeset.idsToDelete)
            )

            operation.modifyRecordsCompletionBlock = { _, _, _ in
                DispatchQueue.main.async { promise(.success(())) }
            }

            self.database.add(operation)
        }
    }

    private func mapToRecords(_ photos: [PhotoToSave], for item: Item) -> [CKRecord] {
        let itemRecord = mapper.map(item).toRecordInZone(zone)
        return photos.compactMap { mapper.map($0).toRecordInZone(zone, referencedBy: itemRecord) }
    }

    private func mapToRecordIds(_ ids: [Id<Photo>]) -> [CKRecord.ID] {
        ids.compactMap { .init(recordName: $0.asString, zoneID: zone.zoneID) }
    }
}
