import CloudKit

public final class CloudKitPersistenceFactory: RemotePersistenceFactory {
    private let configuration: CloudKitConfiguration
    private let fileService: FileService

    public init(containerIdentifier: String, fileService: FileService) {
        self.configuration = CloudKitConfiguration(containerIdentifier: containerIdentifier)
        self.fileService = fileService
    }

    public func itemsService() -> ItemsService {
        CloudKitItemsService(
            configuration: configuration,
            mapper: .init(fileService: fileService),
            notificationCenter: .default
        )
    }

    public func subscriptionService() -> SubscriptionService {
        CloudKitSubscriptionService(configuration: configuration)
    }

    public func sharingControllerFactory() -> SharingControllerFactory {
        CloudKitSharingControllerFactory(configuration: configuration)
    }
}
