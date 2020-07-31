import CloudKit

internal final class CloudKitListMapper {
    private let list: List

    internal init(_ list: List) {
        self.list = list
    }

    internal func toRecordIdInZone(_ zone: CKRecordZone) -> CKRecord.ID? {
        .init(recordName: list.id.asString, zoneID: zone.zoneID)
    }

    internal func toRecord() -> CKRecord? {
        toRecordInZone(.default())
    }

    internal func toRecordInZone(_ zone: CKRecordZone) -> CKRecord? {
        let recordId = CKRecord.ID(recordName: list.id.asString, zoneID: zone.zoneID)
        let record = CKRecord(recordType: "List", recordID: recordId)
        record[CloudKitKey.List.name] = list.name
        record[CloudKitKey.List.updateDate] = list.updateDate
        return record
    }
}
