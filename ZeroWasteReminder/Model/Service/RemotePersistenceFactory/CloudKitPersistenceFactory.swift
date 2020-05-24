import CloudKit

public final class CloudKitPersistenceFactory: RemotePersistenceFactory {
    private let configuration: CloudKitConfiguration

    public init(containerIdentifier: String) {
        configuration = CloudKitConfiguration(containerIdentifier: containerIdentifier)
    }

    public func createItemsService() -> ItemsService {
        CloudKitItemsService(configuration: configuration, mapper: .init(), notificationCenter: .default)
    }

    public func createSubscriptionService() -> SubscriptionService {
        CloudKitSubscriptionService(configuration: configuration)
    }
}
