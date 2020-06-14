import CloudKit

internal final class CloudKitItemMapper {
    private let item: Item
    private let fileService: FileService

    internal init(_ item: Item, _ fileService: FileService) {
        self.item = item
        self.fileService = fileService
    }

    internal func toRecord() -> CKRecord? {
        toRecordInZone(.default())
    }

    internal func toRecordInZone(_ zone: CKRecordZone) -> CKRecord? {
        let recordId = CKRecord.ID(recordName: item.id.uuidString, zoneID: zone.zoneID)
        let record = CKRecord(recordType: "Item", recordID: recordId)
        record[CloudKitKey.Item.name] = item.name
        record[CloudKitKey.Item.notes] = item.notes
        record[CloudKitKey.Item.expiration] = expiration(from: item)
        return record
    }

    private func expiration(from item: Item) -> Date? {
        guard case .date(let date) = item.expiration else {
            return nil
        }

        return date
    }
}
