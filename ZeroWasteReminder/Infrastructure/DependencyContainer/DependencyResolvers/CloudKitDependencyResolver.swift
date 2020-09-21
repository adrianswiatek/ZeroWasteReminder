import Swinject

public final class CloudKitDependencyResolver: DependencyResolver {
    private let container: Container
    private let containerIdentifier: String

    public init(_ container: Container, _ containerIdentifier: String) {
        self.container = container
        self.containerIdentifier = containerIdentifier
    }

    public func registerCoordinators() {}
    public func registerEventListeners() {}

    public func registerOtherObjects() {
        container.register(CloudKitCache.self) { _ in
            CloudKitCache()
        }.inObjectScope(.transient)

        container.register(CloudKitMapper.self) { resolver in
            CloudKitMapper(fileService: resolver.resolve(FileService.self)!)
        }

        container.register(CloudKitConfiguration.self) { [weak self] _ in
            CloudKitConfiguration(containerIdentifier: self?.containerIdentifier ?? "")
        }
    }

    public func registerRepositories() {
        container.register(ListsRepository.self) { resolver in
            CloudKitListsRepository(
                configuration: resolver.resolve(CloudKitConfiguration.self)!,
                cache: resolver.resolve(CloudKitCache.self)!,
                mapper: resolver.resolve(CloudKitMapper.self)!,
                eventDispatcher: resolver.resolve(EventDispatcher.self)!
            )
        }

        container.register(ItemsRepository.self) { resolver in
            CloudKitItemsRepository(
                configuration: resolver.resolve(CloudKitConfiguration.self)!,
                cache: resolver.resolve(CloudKitCache.self)!,
                mapper: resolver.resolve(CloudKitMapper.self)!,
                eventDispatcher: resolver.resolve(EventDispatcher.self)!
            )
        }

        container.register(PhotosRepository.self) { resolver in
            CloudKitPhotosRepository(
                configuration: resolver.resolve(CloudKitConfiguration.self)!,
                mapper: resolver.resolve(CloudKitMapper.self)!,
                eventDispatcher: resolver.resolve(EventDispatcher.self)!
            )
        }
    }

    public func registerServices() {
        container.register(AccountService.self) { resolver in
            CloudKitAccountService(
                configuration: resolver.resolve(CloudKitConfiguration.self)!,
                notificationCenter: resolver.resolve(NotificationCenter.self)!
            )
        }.inObjectScope(.container)

        container.register(SubscriptionService.self) { resolver in
            CloudKitSubscriptionService(
                configuration: resolver.resolve(CloudKitConfiguration.self)!,
                statusNotifier: resolver.resolve(StatusNotifier.self)!
            )
        }.inObjectScope(.container)
    }

    public func registerViewControllerFactories() {}
    public func registerViewModelFactories() {}
}
