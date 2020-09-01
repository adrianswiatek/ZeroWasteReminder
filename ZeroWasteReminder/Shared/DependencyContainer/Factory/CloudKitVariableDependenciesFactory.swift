import Foundation

internal final class CloudKitVariableDependenciesFactory: VariableDependenciesFactory {
    private let configuration: CloudKitConfiguration
    private let notificationCenter: NotificationCenter

    private let listsCache: CloudKitCache
    private let mapper: CloudKitMapper

    internal init(
        containerIdentifier: String,
        listsCache: CloudKitCache,
        fileService: FileService,
        notificationCenter: NotificationCenter
    ) {
        self.notificationCenter = notificationCenter
        self.listsCache = listsCache
        self.configuration = CloudKitConfiguration(containerIdentifier: containerIdentifier)
        self.mapper = CloudKitMapper(fileService: fileService)
    }

    internal lazy var accountService: AccountService =
        CloudKitAccountService(
            configuration: configuration,
            notificationCenter: notificationCenter
        )

    internal lazy var subscriptionService: SubscriptionService =
        CloudKitSubscriptionService(
            configuration: configuration,
            statusNotifier: statusNotifier
        )

    internal lazy var itemsRepository: ItemsRepository =
        CloudKitItemsRepository(
            configuration: configuration,
            cache: InMemoryCloudKitCache(),
            mapper: mapper
        )

    internal lazy var listsRepository: ListsRepository =
        CloudKitListsRepository(
            configuration: configuration,
            cache: InMemoryCloudKitCache(),
            mapper: mapper
        )

    internal lazy var photosRepository: PhotosRepository =
        CloudKitPhotosRepository(configuration: configuration, mapper: mapper)

    internal lazy var sharingControllerFactory: SharingControllerFactory =
        CloudKitSharingControllerFactory(configuration: configuration)

    internal lazy var statusNotifier: StatusNotifier =
        RemoteStatusNotifier(accountService: accountService)
}
