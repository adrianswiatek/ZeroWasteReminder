import Foundation
import Swinject

internal struct StorageDependencyRecorder: DependenciesRecorder {
    private let mainContainer: Container
    private let localContainer: Container
    private let remoteContainer: Container

    internal init(
        _ mainContainer: Container,
        _ localStorageContainer: Container,
        _ remoteStorageContainer: Container
    ) {
        self.mainContainer = mainContainer
        self.localContainer = localStorageContainer
        self.remoteContainer = remoteStorageContainer
    }

    internal func register() {
        registerServices()
        registerRepositories()
    }

    private func registerServices() {
        mainContainer.register(AccountService.self) { _ in
            remoteContainer.resolve(AccountService.self)!
        }.inObjectScope(.container)

        mainContainer.register(SubscriptionService.self) { _ in
            remoteContainer.resolve(SubscriptionService.self)!
        }.inObjectScope(.container)
    }

    private func registerRepositories() {
        mainContainer.register(ListsRepository.self) { _ in
            remoteContainer.resolve(ListsRepository.self)!
        }

        mainContainer.register(ItemsReadRepository.self) { resolver in
            ItemsRepositoryNotificationsDecorator(
                itemsRepository: remoteContainer.resolve(ItemsReadRepository.self)!,
                notificationsRepository: resolver.resolve(ItemNotificationsRepository.self)!
            )
        }

        mainContainer.register(ItemsWriteRepository.self) { _ in
            remoteContainer.resolve(ItemsWriteRepository.self)!
        }

        mainContainer.register(PhotosRepository.self) { _ in
            remoteContainer.resolve(PhotosRepository.self)!
        }

        mainContainer.register(ItemNotificationsRepository.self) { _ in
            localContainer.resolve(ItemNotificationsRepository.self)!
        }
    }
}
