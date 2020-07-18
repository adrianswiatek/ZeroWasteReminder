public protocol RemotePersistenceFactory {
    func itemsService() -> ItemsService
    func photosRepository() -> PhotosRepository
    func accountService() -> AccountService
    func subscriptionService(remoteStatusNotifier: RemoteStatusNotifier) -> SubscriptionService
    func sharingControllerFactory() -> SharingControllerFactory
}
