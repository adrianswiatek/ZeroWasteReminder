import CloudKit

internal final class CloudKitRecordMapper {
    private let record: CKRecord?
    private let fileService: FileService

    internal init(_ record: CKRecord?, _ fileService: FileService) {
        self.record = record
        self.fileService = fileService
    }

    internal func toFullSize() -> Photo? {
        photo(forKey: CloudKitKey.Photo.fullSize)
    }

    internal func toThumbnail() -> Photo? {
        photo(forKey: CloudKitKey.Photo.thumbnail)
    }

    internal func toList() -> List? {
        guard
            let record = record,
            let name = record[CloudKitKey.List.name] as? String,
            let updateDate = record[CloudKitKey.List.updateDate] as? Date
        else { return nil }

        return List(id: .fromString(record.recordID.recordName), name: name, updateDate: updateDate)
    }

    internal func toItem() -> Item? {
        guard
            let record = record,
            let name = record[CloudKitKey.Item.name] as? String,
            let listId = listId(from: record)
        else { return nil }

        return Item(
            id: .fromString(record.recordID.recordName),
            name: name,
            notes: notes(from: record),
            expiration: (record[CloudKitKey.Item.expiration] as? Date).map { .date($0) } ?? .none,
            alertOption: .none,
            listId: listId
        )
    }

    internal func updatedBy(_ list: List?) -> CloudKitRecordMapper {
        guard let record = record, let list = list else { return self }

        applyChange(to: record, key: CloudKitKey.List.name, value: list.name)
        applyChange(to: record, key: CloudKitKey.List.updateDate, value: list.updateDate)

        return self
    }

    internal func updatedBy(_ item: Item?) -> CloudKitRecordMapper {
        guard let record = record, let item = item else { return self }

        applyChange(to: record, key: CloudKitKey.Item.name, value: item.name)
        applyChange(to: record, key: CloudKitKey.Item.notes, value: item.notes)
        applyChange(to: record, key: CloudKitKey.Item.expiration, value: expiration(from: item))
        applyChange(to: record, key: CloudKitKey.Item.listReference, value: listReference(from: item, and: record))

        return self
    }

    internal func toRecord() -> CKRecord? {
        record
    }

    private func notes(from record: CKRecord) -> String {
        record[CloudKitKey.Item.notes] as? String ?? ""
    }

    private func listReference(from item: Item, and record: CKRecord) -> CKRecord.Reference {
        .init(recordID: .init(recordName: item.listId.asString, zoneID: record.recordID.zoneID), action: .deleteSelf)
    }

    private func listId(from record: CKRecord) -> Id<List>? {
        let listReference = record[CloudKitKey.Item.listReference] as? CKRecord.Reference
        return listReference.map { .fromString($0.recordID.recordName) }
    }

    private func expiration(from item: Item) -> Date? {
        guard case .date(let date) = item.expiration else {
            return nil
        }

        return date
    }

    private func photo(forKey key: String) -> Photo? {
        guard
            let id = record.map({ Id<Photo>.fromString($0.recordID.recordName) }),
            let asset = record?[key] as? CKAsset
        else { return nil }

        return asset.fileURL
            .flatMap { try? Data(contentsOf: $0) }
            .map { .init(id: id, data: $0) }
    }

    private func applyChange<T: Equatable & CKRecordValueProtocol>(to record: CKRecord, key: String, value: T?) {
        let valueForGivenKeyExists = record.allKeys().first(where: { $0 == key }) != nil
        guard !valueForGivenKeyExists || record[key] != value else { return }
        record[key] = value
    }
}
