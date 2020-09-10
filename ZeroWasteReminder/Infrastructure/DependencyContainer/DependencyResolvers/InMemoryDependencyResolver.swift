import Swinject

public final class InMemoryDependencyResolver: DependencyResolver {
    private let container: Container

    public init(_ container: Container) {
        self.container = container
    }

    public func registerCoordinators() {}
    public func registerEventListeners() {}
    public func registerOtherObjects() {}

    public func registerRepositories() {
        container.register(ListsRepository.self) { resolver in
            InMemoryListsRepository(eventDispatcher: resolver.resolve(EventDispatcher.self)!)
        }

        container.register(ItemsRepository.self) { resolver in
            InMemoryItemsRepository(eventDispatcher: resolver.resolve(EventDispatcher.self)!)
        }

        container.register(PhotosRepository.self) { _ in
            InMemoryPhotosRepository()
        }
    }

    public func registerServices() {
        container.register(AccountService.self) { _ in
            AlwaysEligibleAccountService()
        }.inObjectScope(.container)

        container.register(SubscriptionService.self) { _ in
            EmptySubscriptionService()
        }
    }

    public func registerViewControllerFactories() {}
    public func registerViewModelFactories() {}
}
