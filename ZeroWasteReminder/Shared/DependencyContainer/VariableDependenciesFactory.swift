internal protocol VariableDependenciesFactory {
    var accountService: AccountService { get }
    var itemsRepository: ItemsRepository { get }
    var itemsService: ItemsService { get }
    var listsRepository: ListsRepository { get }
    var photosRepository: PhotosRepository { get }
    var sharingControllerFactory: SharingControllerFactory { get }
    var statusNotifier: StatusNotifier { get }
    var subscriptionService: SubscriptionService { get }
}
