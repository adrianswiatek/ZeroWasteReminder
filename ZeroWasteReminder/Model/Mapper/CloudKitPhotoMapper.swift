import CloudKit

internal final class CloudKitPhotoMapper {
    private let photo: Photo
    private let fileService: FileService

    internal init(_ photo: Photo, _ fileService: FileService) {
        self.photo = photo
        self.fileService = fileService
    }

    internal func toRecordInZone(_ zone: CKRecordZone, referencedBy itemRecord: CKRecord? = nil) -> CKRecord? {
        let recordId = CKRecord.ID(recordName: photo.id.uuidString, zoneID: zone.zoneID)
        let record = CKRecord(recordType: "Photo", recordID: recordId)
        record[CloudKitKey.Photo.id] = photo.id.uuidString
        record[CloudKitKey.Photo.photo] = photoAsset()
        record[CloudKitKey.Photo.itemId] = itemId(for: itemRecord)
        return record
    }

    private func photoAsset() -> CKAsset? {
        fileService.trySaveData(photo.asData()).map { .init(fileURL: $0) }
    }

    private func itemId(for itemRecord: CKRecord?) -> CKRecord.Reference? {
        itemRecord.map { CKRecord.Reference(record: $0, action: .deleteSelf) }
    }
}
