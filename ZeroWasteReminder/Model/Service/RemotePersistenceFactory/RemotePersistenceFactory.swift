public protocol RemotePersistenceFactory {
    func itemsService() -> ItemsService
    func photosRepository() -> PhotosRepository
    func accountService() -> AccountService
    func subscriptionService(statusNotifier: StatusNotifier) -> SubscriptionService
    func sharingControllerFactory() -> SharingControllerFactory
}
