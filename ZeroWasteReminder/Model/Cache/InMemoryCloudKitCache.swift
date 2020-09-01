import CloudKit

public final class InMemoryCloudKitCache: CloudKitCache {
    private var cache: [CKRecord.ID: CKRecord]

    public init() {
        cache = [:]
    }

    public func findById(_ id: CKRecord.ID) -> CKRecord? {
        cache[id]
    }

    public func findByIds(_ ids: [CKRecord.ID]) -> [CKRecord] {
        ids.compactMap { cache[$0] }
    }

    public func set(_ record: CKRecord) {
        cache[record.recordID] = record
    }

    public func set(_ records: [CKRecord]) {
        records.forEach { set($0) }
    }

    public func removeById(_ id: CKRecord.ID) {
        cache.removeValue(forKey: id)
    }

    public func removeByIds(_ ids: [CKRecord.ID]) {
        ids.forEach(removeById)
    }

    public func invalidate() {
        cache = [:]
    }
}
