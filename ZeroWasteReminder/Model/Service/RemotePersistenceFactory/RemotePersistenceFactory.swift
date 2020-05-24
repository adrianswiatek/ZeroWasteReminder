public protocol RemotePersistenceFactory {
    func createItemsService() -> ItemsService
    func createSubscriptionService() -> SubscriptionService
}
