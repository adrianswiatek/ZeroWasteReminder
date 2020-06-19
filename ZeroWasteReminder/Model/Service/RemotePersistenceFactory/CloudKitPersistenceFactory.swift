import CloudKit

public final class CloudKitPersistenceFactory: RemotePersistenceFactory {
    private let configuration: CloudKitConfiguration
    private let fileService: FileService
    private let notificationCenter: NotificationCenter

    public init(
        containerIdentifier: String,
        fileService: FileService,
        notificationCenter: NotificationCenter
    ) {
        self.configuration = CloudKitConfiguration(containerIdentifier: containerIdentifier)
        self.fileService = fileService
        self.notificationCenter = notificationCenter
    }

    public func itemsService() -> ItemsService {
        CloudKitItemsService(
            configuration: configuration,
            mapper: .init(fileService: fileService),
            notificationCenter: notificationCenter
        )
    }

    public func accountService() -> AccountService {
        CloudKitAccountService(
            configuration: configuration,
            notificationCenter: notificationCenter
        )
    }

    public func subscriptionService(remoteStatusNotifier: RemoteStatusNotifier) -> SubscriptionService {
        CloudKitSubscriptionService(configuration: configuration, remoteStatusNotifier: remoteStatusNotifier)
    }

    public func sharingControllerFactory() -> SharingControllerFactory {
        CloudKitSharingControllerFactory(configuration: configuration)
    }
}
