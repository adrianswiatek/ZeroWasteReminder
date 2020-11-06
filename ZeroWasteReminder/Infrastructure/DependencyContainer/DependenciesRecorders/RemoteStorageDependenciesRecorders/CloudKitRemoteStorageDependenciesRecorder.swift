import Foundation
import Swinject

internal struct CloudKitRemoteStorageDependenciesRecorder: RemoteStorageDependenciesRecorder {
    internal let container: Container

    private let parentContainer: Container
    private let containerIdentifier: String

    internal init(_ parentContainer: Container, _ containerIdentifier: String) {
        self.parentContainer = parentContainer
        self.containerIdentifier = containerIdentifier
        self.container = Container()
    }

    internal func register() {
        registerOtherObjects()
        registerServices()
        registerRepositories()
    }

    internal func registerOtherObjects() {
        container.register(CloudKitCache.self) { _ in
            CloudKitCache()
        }.inObjectScope(.transient)

        container.register(CloudKitMapper.self) { _ in
            CloudKitMapper(fileService: parentContainer.resolve(FileService.self)!)
        }

        container.register(CloudKitConfiguration.self) { _ in
            CloudKitConfiguration(containerIdentifier: containerIdentifier)
        }
    }

    internal func registerServices() {
        container.register(AccountService.self) { resolver in
            CloudKitAccountService(
                configuration: resolver.resolve(CloudKitConfiguration.self)!,
                notificationCenter: parentContainer.resolve(NotificationCenter.self)!
            )
        }

        container.register(SubscriptionService.self) { resolver in
            CloudKitSubscriptionService(
                configuration: resolver.resolve(CloudKitConfiguration.self)!,
                statusNotifier: parentContainer.resolve(StatusNotifier.self)!
            )
        }
    }

    internal func registerRepositories() {
        container.register(ListsRepository.self) { resolver in
            CloudKitListsRepository(
                configuration: resolver.resolve(CloudKitConfiguration.self)!,
                cache: resolver.resolve(CloudKitCache.self)!,
                mapper: resolver.resolve(CloudKitMapper.self)!,
                eventDispatcher: parentContainer.resolve(EventDispatcher.self)!
            )
        }

        container.register(CloudKitItemsRepository.self) { resolver in
            CloudKitItemsRepository(
                configuration: resolver.resolve(CloudKitConfiguration.self)!,
                cache: resolver.resolve(CloudKitCache.self)!,
                mapper: resolver.resolve(CloudKitMapper.self)!,
                eventDispatcher: parentContainer.resolve(EventDispatcher.self)!
            )
        }

        container.register(ItemsReadRepository.self) { resolver in
            resolver.resolve(CloudKitItemsRepository.self)!
        }

        container.register(ItemsWriteRepository.self) { resolver in
            resolver.resolve(CloudKitItemsRepository.self)!
        }

        container.register(PhotosRepository.self) { resolver in
            CloudKitPhotosRepository(
                configuration: resolver.resolve(CloudKitConfiguration.self)!,
                mapper: resolver.resolve(CloudKitMapper.self)!,
                eventDispatcher: parentContainer.resolve(EventDispatcher.self)!
            )
        }
    }
}
