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
        let record = CKRecord(recordType: "Item", recordID: .init(recordName: item.id.uuidString))
        record[Item.Key.name] = item.name
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
            let name = record[Item.Key.name] as? String
        else { return nil }

        if let date = record[Item.Key.expiration] as? Date {
            return Item(id: id, name: name, expiration: .date(date))
        }

        return Item(id: id, name: name, expiration: .none)
    }

    func updateBy(_ item: Item?) -> CloudKitRecordMapper {
        guard let record = record, let item = item else { return self }

        record[Item.Key.name] = item.name
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
        static let expiration = "expiration"
    }
}
