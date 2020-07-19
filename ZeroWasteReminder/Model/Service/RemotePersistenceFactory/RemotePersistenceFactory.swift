public protocol RemotePersistenceFactory {
    func accountService() -> AccountService
    func subscriptionService(statusNotifier: StatusNotifier) -> SubscriptionService

    func itemsRepository() -> ItemsRepository
    func listsRepository() -> ListsRepository
    func photosRepository() -> PhotosRepository

    func sharingControllerFactory() -> SharingControllerFactory
}
