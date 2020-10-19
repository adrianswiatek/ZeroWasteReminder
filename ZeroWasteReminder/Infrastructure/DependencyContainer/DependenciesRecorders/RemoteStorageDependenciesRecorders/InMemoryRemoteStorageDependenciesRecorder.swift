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
        container.register(AccountService.self) { resolver in
            AlwaysEligibleAccountService()
        }.inObjectScope(.container)

        container.register(SubscriptionService.self) { resolver in
            EmptySubscriptionService()
        }.inObjectScope(.container)
    }

    private func registerRepositories() {
        container.register(ListsRepository.self) { resolver in
            InMemoryListsRepository(
                eventDispatcher: parentContainer.resolve(EventDispatcher.self)!
            )
        }

        container.register(ItemsReadRepository.self) { resolver in
            InMemoryItemsRepository(
                eventDispatcher: parentContainer.resolve(EventDispatcher.self)!
            )
        }

        container.register(ItemsWriteRepository.self) { resolver in
            InMemoryItemsRepository(
                eventDispatcher: parentContainer.resolve(EventDispatcher.self)!
            )
        }

        container.register(PhotosRepository.self) { resolver in
            InMemoryPhotosRepository(
                eventDispatcher: parentContainer.resolve(EventDispatcher.self)!
            )
        }
    }
}
