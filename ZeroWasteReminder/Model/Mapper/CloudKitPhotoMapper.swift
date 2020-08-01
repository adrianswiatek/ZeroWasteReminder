import CloudKit

internal final class CloudKitPhotoMapper {
    private let photo: PhotoToSave
    private let fileService: FileService

    internal init(_ photo: PhotoToSave, _ fileService: FileService) {
        self.photo = photo
        self.fileService = fileService
    }

    internal func toRecordInZone(_ zone: CKRecordZone, referencedBy itemRecord: CKRecord? = nil) -> CKRecord? {
        let recordId = CKRecord.ID(recordName: photo.id.asString, zoneID: zone.zoneID)
        let record = CKRecord(recordType: "Photo", recordID: recordId)
        record[CloudKitKey.Photo.fullSize] = photoAsset(forPhoto: photo.fullSize)
        record[CloudKitKey.Photo.thumbnail] = photoAsset(forPhoto: photo.thumbnail)
        record[CloudKitKey.Photo.itemReference] = itemReference(for: itemRecord)
        return record
    }

    private func photoAsset(forPhoto photo: Photo) -> CKAsset? {
        fileService.trySaveData(photo.asData()).map { .init(fileURL: $0) }
    }

    private func itemReference(for itemRecord: CKRecord?) -> CKRecord.Reference? {
        itemRecord.map { CKRecord.Reference(record: $0, action: .deleteSelf) }
    }
}
