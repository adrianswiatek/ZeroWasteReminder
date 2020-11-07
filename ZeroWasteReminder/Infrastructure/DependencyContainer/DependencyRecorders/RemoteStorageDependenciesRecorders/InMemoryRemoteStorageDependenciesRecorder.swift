import Swinject

internal struct InMemoryRemoteStorageDependenciesRecorder: RemoteStorageDependenciesRecorder {
    internal let container: Container
    private let parentContainer: Container

    internal init(_ parentContainer: Container) {
        self.parentContainer = parentContainer
        self.container = Container()
    }

    internal func register() {
        registerServices()
        registerRepositories()
    }

    private func registerServices() {
        container.register(AccountService.self) { _ in
            AlwaysEligibleAccountService()
        }.inObjectScope(.container)

        container.register(SubscriptionService.self) { _ in
            EmptySubscriptionService()
        }.inObjectScope(.container)
    }

    private func registerRepositories() {
        container.register(ListsRepository.self) { _ in
            InMemoryListsRepository(
                eventDispatcher: parentContainer.resolve(EventDispatcher.self)!
            )
        }

        container.register(InMemoryItemsRepository.self) { _ in
            InMemoryItemsRepository(
                eventDispatcher: parentContainer.resolve(EventDispatcher.self)!
            )
        }.inObjectScope(.container)

        container.register(ItemsReadRepository.self) { resolver in
            resolver.resolve(InMemoryItemsRepository.self)!
        }

        container.register(ItemsWriteRepository.self) { resolver in
            resolver.resolve(InMemoryItemsRepository.self)!
        }

        container.register(PhotosRepository.self) { _ in
            InMemoryPhotosRepository(
                eventDispatcher: parentContainer.resolve(EventDispatcher.self)!
            )
        }
    }
}
