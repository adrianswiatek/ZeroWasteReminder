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
    private let eventDispatcher: EventDispatcher

    public init(
        configuration: CloudKitConfiguration,
        mapper: CloudKitMapper,
        eventDispatcher: EventDispatcher
    ) {
        self.configuration = configuration
        self.mapper = mapper
        self.eventDispatcher = eventDispatcher
    }

    public func fetchThumbnail(with id: Id<Photo>) -> Future<Photo?, Never> {
        Future { [weak self] promise in
            guard let self = self else { return promise(.success(nil)) }

            let recordId = CKRecord.ID(recordName: id.asString, zoneID: self.zone.zoneID)
            let query = CKQuery(recordType: "Photo", predicate: .init(format: "%K == %@", "recordID", recordId))
            let operation = CKQueryOperation(query: query)

            var record: CKRecord?
            var error: Error?

            operation.recordFetchedBlock = { record = $0 }
            operation.queryCompletionBlock = { error = $1 }

            operation.completionBlock = {
                if let error = error {
                    self.eventDispatcher.dispatch(ErrorOccured(.init(error)))
                } else {
                    let thumbnail = self.mapper.map(record).toThumbnail()
                    DispatchQueue.main.async { promise(.success(thumbnail)) }
                }
            }

            self.database.add(operation)
        }
    }

    public func fetchThumbnails(for item: Item) -> Future<[Photo], Never> {
        Future { [weak self] promise in
            guard let self = self else { return promise(.success([])) }

            let itemReference = CKRecord.Reference(
                recordID: .init(recordName: item.id.asString, zoneID: self.zone.zoneID),
                action: .none
            )

            let predicate = NSPredicate(format: "%K == %@", CloudKitKey.Photo.itemReference, itemReference)

            let operation = CKQueryOperation(query: .init(recordType: "Photo", predicate: predicate))
            operation.desiredKeys = [CloudKitKey.Photo.thumbnail]

            var records: [CKRecord] = []
            var error: Error? = nil

            operation.recordFetchedBlock = { records.append($0) }
            operation.queryCompletionBlock = { error = $1 }
            operation.completionBlock = {
                if let error = error {
                    self.eventDispatcher.dispatch(ErrorOccured(.init(error)))
                } else {
                    let photos = records.compactMap { self.mapper.map($0).toThumbnail() }
                    DispatchQueue.main.async { promise(.success(photos)) }
                }
            }

            self.database.add(operation)
        }
    }

    public func fetchFullSize(with photoId: Id<Photo>) -> Future<Photo?, Never> {
        Future { [weak self] promise in
            guard let self = self else { return promise(.success(nil)) }

            let recordId = CKRecord.ID(recordName: photoId.asString, zoneID: self.zone.zoneID)
            let predicate = NSPredicate(format: "%K == %@", "recordID", recordId)

            let operation = CKQueryOperation(query: .init(recordType: "Photo", predicate: predicate))
            operation.desiredKeys = [CloudKitKey.Photo.fullSize]

            var record: CKRecord?
            var error: Error?

            operation.recordFetchedBlock = { record = $0 }
            operation.queryCompletionBlock = { error = $1 }
            operation.completionBlock = {
                if let error = error {
                    self.eventDispatcher.dispatch(ErrorOccured(.init(error)))
                } else {
                    let fullSize = record.flatMap { self.mapper.map($0).toFullSize() }
                    DispatchQueue.main.async { promise(.success(fullSize)) }
                }
            }

            self.database.add(operation)
        }
    }

    public func update(_ photosChangeset: PhotosChangeset, for item: Item) {
        guard photosChangeset.hasChanges else {
            return eventDispatcher.dispatch(NoResultOccured())
        }

        let operation = CKModifyRecordsOperation(
            recordsToSave: mapToRecords(photosChangeset.photosToSave, for: item),
            recordIDsToDelete: mapToRecordIds(photosChangeset.idsToDelete)
        )

        operation.modifyRecordsCompletionBlock = { [weak self] _, _, _ in
            self?.eventDispatcher.dispatch(PhotosUpdated(item.id))
        }

        database.add(operation)
    }

    private func mapToRecords(_ photos: [PhotoToSave], for item: Item) -> [CKRecord] {
        let itemRecord = mapper.map(item).toRecordInZone(zone)
        return photos.compactMap { mapper.map($0).toRecordInZone(zone, referencedBy: itemRecord) }
    }

    private func mapToRecordIds(_ ids: [Id<Photo>]) -> [CKRecord.ID] {
        ids.compactMap { .init(recordName: $0.asString, zoneID: zone.zoneID) }
    }
}
