import CloudKit

internal final class CloudKitRecordMapper {
    private let record: CKRecord?
    private let fileService: FileService

    internal init(_ record: CKRecord?, _ fileService: FileService) {
        self.record = record
        self.fileService = fileService
    }

    internal func toPhoto() -> Photo? {
        guard let record = record, let id = UUID(uuidString: record.recordID.recordName) else {
            return nil
        }

        return (record[CloudKitKey.Photo.photo] as? CKAsset)
            .flatMap { $0.fileURL }
            .flatMap { try? Data(contentsOf: $0) }
            .map { Photo(id: id, data: $0) }
    }

    internal func toItem() -> Item? {
        guard
            let record = record,
            let id = UUID(uuidString: record.recordID.recordName),
            let name = record[CloudKitKey.Item.name] as? String
        else { return nil }

        let notes = self.notes(from: record)

        if let date = record[CloudKitKey.Item.expiration] as? Date {
            return Item(id: id, name: name, notes: notes, expiration: .date(date), photos: [])
        }

        return Item(id: id, name: name, notes: notes, expiration: .none, photos: [])
    }

    internal func updateBy(_ item: Item?) -> CloudKitRecordMapper {
        guard let record = record, let item = item else { return self }
        record[CloudKitKey.Item.name] = item.name
        record[CloudKitKey.Item.notes] = item.notes
        record[CloudKitKey.Item.expiration] = expiration(from: item)
        return self
    }

    internal func toRecord() -> CKRecord? {
        record
    }

    private func notes(from record: CKRecord) -> String {
        record[CloudKitKey.Item.notes] as? String ?? ""
    }

    private func expiration(from item: Item) -> Date? {
        guard case .date(let date) = item.expiration else {
            return nil
        }

        return date
    }
}
