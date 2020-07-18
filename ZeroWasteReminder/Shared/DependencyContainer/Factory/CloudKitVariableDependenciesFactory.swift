import Foundation

internal final class CloudKitVariableDependenciesFactory: VariableDependenciesFactory {
    private let configuration: CloudKitConfiguration
    private let notificationCenter: NotificationCenter
    private let mapper: CloudKitMapper

    internal init(
        containerIdentifier: String,
        fileService: FileService,
        notificationCenter: NotificationCenter
    ) {
        self.notificationCenter = notificationCenter
        self.configuration = CloudKitConfiguration(containerIdentifier: containerIdentifier)
        self.mapper = .init(fileService: fileService)
    }

    internal lazy var accountService: AccountService =
        CloudKitAccountService(
            configuration: configuration,
            notificationCenter: notificationCenter
        )

    internal lazy var itemsRepository: ItemsRepository =
        InMemoryItemsRepository()

    internal lazy var itemsService: ItemsService =
        CloudKitItemsService(
            configuration: configuration,
            itemsRepository: itemsRepository,
            mapper: mapper,
            notificationCenter: notificationCenter
        )

    internal lazy var listsRepository: ListsRepository =
        InMemoryListsRepository()

    internal lazy var photosRepository: PhotosRepository =
        CloudKitPhotosRepository(
            configuration: configuration,
            itemsRepository: itemsRepository,
            mapper: mapper
        )

    internal lazy var sharingControllerFactory: SharingControllerFactory =
        CloudKitSharingControllerFactory(configuration: configuration)

    internal lazy var statusNotifier: StatusNotifier =
        RemoteStatusNotifier(accountService: accountService)

    internal lazy var subscriptionService: SubscriptionService = CloudKitSubscriptionService(
        configuration: configuration,
        statusNotifier: statusNotifier
    )
}
