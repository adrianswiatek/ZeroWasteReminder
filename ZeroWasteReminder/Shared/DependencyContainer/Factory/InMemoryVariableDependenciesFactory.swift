internal final class InMemoryVariableDependenciesFactory: VariableDependenciesFactory {
    internal lazy var accountService: AccountService = InMemoryAccountService()
    internal lazy var itemsRepository: ItemsRepository = InMemoryItemsRepository()
    internal lazy var itemsService: ItemsService = InMemoryItemsService(itemsRepository: itemsRepository)
    internal lazy var listsRepository: ListsRepository = InMemoryListsRepository()
    internal lazy var photosRepository: PhotosRepository = InMemoryPhotosRepository()
    internal lazy var sharingControllerFactory: SharingControllerFactory = EmptySharingControllerFactory()
    internal lazy var statusNotifier: StatusNotifier = EmptyStatusNotifier()
    internal lazy var subscriptionService: SubscriptionService = EmptySubscriptionService()
}
