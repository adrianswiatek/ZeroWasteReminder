internal protocol VariableDependenciesFactory {
    var accountService: AccountService { get }
    var subscriptionService: SubscriptionService { get }

    var itemsRepository: ItemsRepository { get }
    var listsRepository: ListsRepository { get }
    var photosRepository: PhotosRepository { get }

    var sharingControllerFactory: SharingControllerFactory { get }
    var statusNotifier: StatusNotifier { get }
}
