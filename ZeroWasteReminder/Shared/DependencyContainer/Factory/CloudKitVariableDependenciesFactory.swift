import Foundation

internal final class CloudKitVariableDependenciesFactory: VariableDependenciesFactory {
    private let configuration: CloudKitConfiguration
    private let notificationCenter: NotificationCenter

    private let itemsCache: CloudKitCache
    private let listsCache: CloudKitCache

    private let mapper: CloudKitMapper

    internal init(
        configuration: CloudKitConfiguration,
        itemsCache: CloudKitCache,
        listsCache: CloudKitCache,
        mapper: CloudKitMapper,
        notificationCenter: NotificationCenter
    ) {
        self.configuration = configuration
        self.itemsCache = itemsCache
        self.listsCache = listsCache
        self.mapper = mapper
        self.notificationCenter = notificationCenter
    }

    internal lazy var accountService: AccountService =
        CloudKitAccountService(configuration: configuration, notificationCenter: notificationCenter)

    internal lazy var subscriptionService: SubscriptionService =
        CloudKitSubscriptionService(configuration: configuration, statusNotifier: statusNotifier)

    internal lazy var itemsRepository: ItemsRepository =
        CloudKitItemsRepository(configuration: configuration, cache: itemsCache, mapper: mapper)

    internal lazy var listsRepository: ListsRepository =
        CloudKitListsRepository(configuration: configuration, cache: listsCache, mapper: mapper)

    internal lazy var photosRepository: PhotosRepository =
        CloudKitPhotosRepository(configuration: configuration, mapper: mapper)

    internal lazy var sharingControllerFactory: SharingControllerFactory =
        CloudKitSharingControllerFactory(configuration: configuration)

    internal lazy var statusNotifier: StatusNotifier =
        RemoteStatusNotifier(accountService: accountService)
}
