public protocol RemotePersistenceFactory {
    func itemsService() -> ItemsService
    func photosService() -> PhotosService
    func accountService() -> AccountService
    func subscriptionService(remoteStatusNotifier: RemoteStatusNotifier) -> SubscriptionService
    func sharingControllerFactory() -> SharingControllerFactory
}
