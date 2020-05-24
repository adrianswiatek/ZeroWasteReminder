import CloudKit

public final class CloudKitPersistenceFactory: RemotePersistenceFactory {
    private let configuration: CloudKitConfiguration

    public init(containerIdentifier: String) {
        configuration = CloudKitConfiguration(containerIdentifier: containerIdentifier)
    }

    public func itemsService() -> ItemsService {
        CloudKitItemsService(configuration: configuration, mapper: .init(), notificationCenter: .default)
    }

    public func subscriptionService() -> SubscriptionService {
        CloudKitSubscriptionService(configuration: configuration)
    }

    public func sharingControllerFactory() -> SharingControllerFactory {
        CloudKitSharingControllerFactory(configuration: configuration)
    }
}
