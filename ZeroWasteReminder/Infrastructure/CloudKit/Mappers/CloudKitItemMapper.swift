import CloudKit

internal final class CloudKitItemMapper {
    private let item: Item

    internal init(_ item: Item) {
        self.item = item
    }

    internal func toRecordIdInZone(_ zone: CKRecordZone) -> CKRecord.ID? {
        .init(recordName: item.id.asString, zoneID: zone.zoneID)
    }

    internal func toRecord() -> CKRecord? {
        toRecordInZone(.default())
    }

    internal func toRecordInZone(_ zone: CKRecordZone, referencedBy listRecord: CKRecord? = nil) -> CKRecord? {
        let recordId = CKRecord.ID(recordName: item.id.asString, zoneID: zone.zoneID)
        let record = CKRecord(recordType: "Item", recordID: recordId)
        record[CloudKitKey.Item.name] = item.name
        record[CloudKitKey.Item.notes] = item.notes
        record[CloudKitKey.Item.expiration] = expiration(from: item)
        record[CloudKitKey.Item.listReference] = listReference(for: listRecord)
        return record
    }

    private func expiration(from item: Item) -> Date? {
        guard case .date(let date) = item.expiration else {
            return nil
        }

        return date
    }

    private func listReference(for listRecord: CKRecord?) -> CKRecord.Reference? {
        listRecord.map { .init(record: $0, action: .deleteSelf) }
    }
}
