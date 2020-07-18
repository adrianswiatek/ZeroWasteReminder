import CloudKit

public final class CloudKitPersistenceFactory: RemotePersistenceFactory {
    private let configuration: CloudKitConfiguration
    private let itemsRepository: ItemsRepository
    private let mapper: CloudKitMapper
    private let notificationCenter: NotificationCenter

    public init(
        containerIdentifier: String,
        itemsRepository: ItemsRepository,
        fileService: FileService,
        notificationCenter: NotificationCenter
    ) {
        self.configuration = CloudKitConfiguration(containerIdentifier: containerIdentifier)
        self.itemsRepository = itemsRepository
        self.mapper = .init(fileService: fileService)
        self.notificationCenter = notificationCenter
    }

    public func itemsService() -> ItemsService {
        CloudKitItemsService(
            configuration: configuration,
            itemsRepository: itemsRepository,
            mapper: mapper,
            notificationCenter: notificationCenter
        )
    }

    public func photosRepository() -> PhotosRepository {
        CloudKitPhotosRepository(
            configuration: configuration,
            itemsRepository: itemsRepository,
            mapper: mapper
        )
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

    public func sharingControllerFactory() -> SharingControllerFactory {
        CloudKitSharingControllerFactory(configuration: configuration)
    }
}
