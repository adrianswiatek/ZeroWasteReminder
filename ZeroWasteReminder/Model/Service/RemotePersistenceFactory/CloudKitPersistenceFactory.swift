import CloudKit

public final class CloudKitPersistenceFactory: RemotePersistenceFactory {
    private let configuration: CloudKitConfiguration
    private let itemsRepository: ItemsRepository
    private let fileService: FileService
    private let notificationCenter: NotificationCenter

    public init(
        containerIdentifier: String,
        itemsRepository: ItemsRepository,
        fileService: FileService,
        notificationCenter: NotificationCenter
    ) {
        self.configuration = CloudKitConfiguration(containerIdentifier: containerIdentifier)
        self.itemsRepository = itemsRepository
        self.fileService = fileService
        self.notificationCenter = notificationCenter
    }

    public func itemsService() -> ItemsService {
        CloudKitItemsService(
            configuration: configuration,
            itemsRepository: itemsRepository,
            mapper: .init(fileService: fileService),
            notificationCenter: notificationCenter
        )
    }

    public func photosService() -> PhotosService {
        CloudKitPhotosService(configuration: configuration, itemsRepository: itemsRepository)
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
