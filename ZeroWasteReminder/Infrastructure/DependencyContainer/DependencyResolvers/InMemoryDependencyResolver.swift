import Swinject

public final class InMemoryDependencyResolver: DependencyResolver {
    private let container: Container

    public init(_ container: Container) {
        self.container = container
    }

    public func registerCoordinators() {}

    public func registerOtherObjects() {
        container.register(EventBus.self) { _ in
            LocalEventBus()
        }.inObjectScope(.container)
    }

    public func registerRepositories() {
        container.register(ListsRepository.self) { resolver in
            InMemoryListsRepository(eventBus: resolver.resolve(EventBus.self)!)
        }

        container.register(ItemsRepository.self) { resolver in
            InMemoryItemsRepository(eventBus: resolver.resolve(EventBus.self)!)
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
