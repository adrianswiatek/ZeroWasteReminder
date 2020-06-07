import CloudKit

public final class CloudKitMapper {
    func map(_ item: Item) -> CloudKitItemMapper {
        .init(item)
    }

    func map(_ record: CKRecord?) -> CloudKitRecordMapper {
        .init(record)
    }
}

public final class CloudKitItemMapper {
    private let item: Item

    init(_ item: Item) {
        self.item = item
    }

    func toRecord() -> CKRecord? {
        toRecordInZone(.default())
    }

    func toRecordInZone(_ zone: CKRecordZone) -> CKRecord? {
        let recordId = CKRecord.ID(recordName: item.id.uuidString, zoneID: zone.zoneID)
        let record = CKRecord(recordType: "Item", recordID: recordId)
        record[Item.Key.name] = item.name
        record[Item.Key.notes] = item.notes
        record[Item.Key.expiration] = nil

        if case .date(let date) = item.expiration {
            record[Item.Key.expiration] = date
        }

        return record
    }
}

public final class CloudKitRecordMapper {
    private let record: CKRecord?

    init(_ record: CKRecord?) {
        self.record = record
    }

    func toItem() -> Item? {
        guard
            let record = record,
            let id = UUID(uuidString: record.recordID.recordName),
            let name = record[Item.Key.name] as? String,
            let notes = record[Item.Key.notes] as? String
        else { return nil }

        if let date = record[Item.Key.expiration] as? Date {
            return Item(id: id, name: name, notes: notes, expiration: .date(date), photos: [])
        }

        return Item(id: id, name: name, notes: notes, expiration: .none, photos: [])
    }

    func updateBy(_ item: Item?) -> CloudKitRecordMapper {
        guard let record = record, let item = item else { return self }

        record[Item.Key.name] = item.name
        record[Item.Key.notes] = item.notes
        record[Item.Key.expiration] = nil

        if case .date(let date) = item.expiration {
            record[Item.Key.expiration] = date
        }

        return self
    }

    public func toRecord() -> CKRecord? {
        record
    }
}

private extension Item {
    enum Key {
        static let id = "id"
        static let name = "name"
        static let notes = "notes"
        static let expiration = "expiration"
    }
}
