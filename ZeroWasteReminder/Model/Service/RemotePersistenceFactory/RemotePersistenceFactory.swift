public protocol RemotePersistenceFactory {
    func itemsService() -> ItemsService
    func subscriptionService() -> SubscriptionService
    func sharingControllerFactory() -> SharingControllerFactory
}
