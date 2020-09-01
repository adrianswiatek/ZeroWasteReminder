import CloudKit

public protocol CloudKitCache {
    func findById(_ id: CKRecord.ID) -> CKRecord?
    func findByIds(_ ids: [CKRecord.ID]) -> [CKRecord]
    func set(_ record: CKRecord)
    func set(_ records: [CKRecord])
    func removeById(_ id: CKRecord.ID)
    func removeByIds(_ ids: [CKRecord.ID])
    func invalidate()
}
