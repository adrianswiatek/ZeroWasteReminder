import CloudKit

public struct CloudKitConfiguration {
    public let container: CKContainer
    public let appZone: CKRecordZone

    public init(containerIdentifier: String) {
        container = CKContainer(identifier: containerIdentifier)
        appZone = CKRecordZone(zoneName: "AppZone")
    }
}
