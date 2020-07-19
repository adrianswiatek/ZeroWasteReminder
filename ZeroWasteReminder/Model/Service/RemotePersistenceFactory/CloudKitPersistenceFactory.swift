import CloudKit

public final class CloudKitPersistenceFactory: RemotePersistenceFactory {
    private let configuration: CloudKitConfiguration
    private let mapper: CloudKitMapper
    private let notificationCenter: NotificationCenter

    public init(
        containerIdentifier: String,
        fileService: FileService,
        notificationCenter: NotificationCenter
    ) {
        self.configuration = CloudKitConfiguration(containerIdentifier: containerIdentifier)
        self.mapper = .init(fileService: fileService)
        self.notificationCenter = notificationCenter
    }

    public func accountService() -> AccountService {
        CloudKitAccountService(
            configuration: configuration,
            notificationCenter: notificationCenter
        )
    }

    public func subscriptionService(statusNotifier: StatusNotifier) -> SubscriptionService {
        CloudKitSubscriptionService(configuration: configuration, statusNotifier: statusNotifier)
    }

    public func itemsRepository() -> ItemsRepository {
        InMemoryItemsRepository()
    }

    public func listsRepository() -> ListsRepository {
        InMemoryListsRepository()
    }

    public func photosRepository() -> PhotosRepository {
        CloudKitPhotosRepository(configuration: configuration, mapper: mapper)
    }

    public func sharingControllerFactory() -> SharingControllerFactory {
        CloudKitSharingControllerFactory(configuration: configuration)
    }
}
