import CloudKit

internal final class CloudKitItemMapper {
    private let itemToSave: ItemToSave
    private let fileService: FileService

    internal init(_ itemToSave: ItemToSave, _ fileService: FileService) {
        self.itemToSave = itemToSave
        self.fileService = fileService
    }

    internal init(_ item: Item, _ fileService: FileService) {

    }

    internal func toRecordIdInZone(_ zone: CKRecordZone) -> CKRecord.ID? {
        .init(recordName: itemToSave.item.id.asString, zoneID: zone.zoneID)
    }

    internal func toRecord() -> CKRecord? {
        toRecordInZone(.default())
    }

    internal func toRecordInZone(_ zone: CKRecordZone) -> CKRecord? {
        let recordId = CKRecord.ID(recordName: itemToSave.item.id.asString, zoneID: zone.zoneID)
        let record = CKRecord(recordType: "Item", recordID: recordId)
        record[CloudKitKey.Item.name] = itemToSave.item.name
        record[CloudKitKey.Item.notes] = itemToSave.item.notes
        record[CloudKitKey.Item.expiration] = expiration(from: itemToSave.item)
        return record
    }

    private func expiration(from item: Item) -> Date? {
        guard case .date(let date) = item.expiration else {
            return nil
        }

        return date
    }
}
