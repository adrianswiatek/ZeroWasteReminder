import CloudKit

public struct CloudKitConfiguration {
    public let container: CKContainer
    public let itemsZone: CKRecordZone

    public init(containerIdentifier: String) {
        container = CKContainer(identifier: containerIdentifier)
        itemsZone = CKRecordZone(zoneName: "ItemsZone")
    }
}
