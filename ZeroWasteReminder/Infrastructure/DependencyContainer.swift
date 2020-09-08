import UIKit
import Swinject

internal final class DependencyContainer {
    private let container: Container

    internal init(configuration: Configuration) {
        container = Container()

        registerServices(in: container, with: configuration)
        registerRepositories(in: container, with: configuration)
        registerOtherObjects(in: container, with: configuration)
        registerViewControllerFactories(in: container, with: configuration)
        registerViewModelFactories(in: container)
        registerCoordinators(in: container)
    }

    internal var rootViewController: UIViewController {
        container.resolve(ListsViewControllerFactory.self)!.create()
    }

    internal func initializeBackgroundServices() {
        container.resolve(AccountService.self)!.refreshUserEligibility()
        container.resolve(SubscriptionService.self)!.registerItemsSubscriptionIfNeeded()
//        container.resolve(EventBusInterceptor.self)!.startIntercept()
    }

    private func registerServices(in container: Container, with configuration: Configuration) {
        container.register(FileService.self) { _ in
            FileService(fileManager: .default)
        }

        container.register(AccountService.self) { resolver in
            switch configuration {
            case .cloudKit:
                return CloudKitAccountService(
                    configuration: resolver.resolve(CloudKitConfiguration.self)!,
                    notificationCenter: resolver.resolve(NotificationCenter.self)!
                )
            case .inMemory:
                return AlwaysEligibleAccountService()
            }
        }.inObjectScope(.container)

        container.register(SubscriptionService.self) { resolver in
            switch configuration {
            case .cloudKit:
                return CloudKitSubscriptionService(
                    configuration: resolver.resolve(CloudKitConfiguration.self)!,
                    statusNotifier: resolver.resolve(StatusNotifier.self)!
                )
            case .inMemory:
                return EmptySubscriptionService()
            }
        }

        container.register(MoveItemService.self) { resolver in
            DefaultMoveItemService(
                listsRepository: resolver.resolve(ListsRepository.self)!,
                itemsRepository: resolver.resolve(ItemsRepository.self)!,
                eventBus: resolver.resolve(EventBus.self)!
            )
        }
    }

    private func registerRepositories(in container: Container, with configuration: Configuration) {
        container.register(CloudKitCache.self) { _ in
            CloudKitCache()
        }.inObjectScope(.transient)

        container.register(CloudKitMapper.self) { resolver in
            CloudKitMapper(fileService: resolver.resolve(FileService.self)!)
        }

        container.register(ListsRepository.self) { resolver in
            switch configuration {
            case .cloudKit:
                return CloudKitListsRepository(
                    configuration: resolver.resolve(CloudKitConfiguration.self)!,
                    cache: resolver.resolve(CloudKitCache.self)!,
                    mapper: resolver.resolve(CloudKitMapper.self)!,
                    eventBus: resolver.resolve(EventBus.self)!
                )
            case .inMemory:
                return InMemoryListsRepository(
                    eventBus: resolver.resolve(EventBus.self)!
                )
            }
        }

        container.register(ItemsRepository.self) { resolver in
            switch configuration {
            case .cloudKit:
                return CloudKitItemsRepository(
                    configuration: resolver.resolve(CloudKitConfiguration.self)!,
                    cache: resolver.resolve(CloudKitCache.self)!,
                    mapper: resolver.resolve(CloudKitMapper.self)!,
                    eventBus: resolver.resolve(EventBus.self)!
                )
            case .inMemory:
                return InMemoryItemsRepository(
                    eventBus: resolver.resolve(EventBus.self)!
                )
            }
        }

        container.register(PhotosRepository.self) { resolver in
            switch configuration {
            case .cloudKit:
                return CloudKitPhotosRepository(
                    configuration: resolver.resolve(CloudKitConfiguration.self)!,
                    mapper: resolver.resolve(CloudKitMapper.self)!
                )
            case .inMemory:
                return InMemoryPhotosRepository()
            }
        }
    }

    private func registerOtherObjects(in container: Container, with configuration: Configuration) {
        container.register(CloudKitConfiguration.self) { _ in
            switch configuration {
            case .cloudKit(let containerIdentifier):
                return CloudKitConfiguration(containerIdentifier: containerIdentifier)
            case .inMemory:
                return CloudKitConfiguration(containerIdentifier: "")
            }
        }

        container.register(SharingControllerFactory.self) { _ in
            EmptySharingControllerFactory()
        }

        container.register(EventBus.self) { _ in
            EventBus()
        }.inObjectScope(.container)

        container.register(NotificationCenter.self) { _ in
            NotificationCenter.default
        }

        container.register(StatusNotifier.self) { resolver in
            RemoteStatusNotifier(accountService: resolver.resolve(AccountService.self)!)
        }.inObjectScope(.container)

        container.register(AutomaticListUpdater.self) { resolver in
            DefaultAutomaticListUpdater(
                resolver.resolve(ListsRepository.self)!,
                resolver.resolve(EventBus.self)!
            )
        }

        container.register(EventBusInterceptor.self) { resolver in
            ConsoleEventBusInterceptor(resolver.resolve(EventBus.self)!)
        }.inObjectScope(.container)
    }

    private func registerViewModelFactories(in container: Container) {
        container.register(ListsViewModelFactory.self) { resolver in
            ListsViewModelFactory(
                listsRepository: resolver.resolve(ListsRepository.self)!,
                listUpdater: resolver.resolve(AutomaticListUpdater.self)!,
                statusNotifier: resolver.resolve(StatusNotifier.self)!,
                eventBus: resolver.resolve(EventBus.self)!
            )
        }

        container.register(ItemsViewModelFactory.self) { resolver in
            ItemsViewModelFactory(
                itemsRepository: resolver.resolve(ItemsRepository.self)!,
                statusNotifier: resolver.resolve(StatusNotifier.self)!,
                eventBus: resolver.resolve(EventBus.self)!
            )
        }

        container.register(MoveItemViewModelFactory.self) { resolver in
            MoveItemViewModelFactory(
                moveItemService: resolver.resolve(MoveItemService.self)!,
                eventBus: resolver.resolve(EventBus.self)!
            )
        }

        container.register(AddViewModelFactory.self) { resolver in
            AddViewModelFactory(
                itemsRepository: resolver.resolve(ItemsRepository.self)!,
                photosRepository: resolver.resolve(PhotosRepository.self)!,
                fileService: resolver.resolve(FileService.self)!,
                statusNotifier: resolver.resolve(StatusNotifier.self)!,
                eventBus: resolver.resolve(EventBus.self)!
            )
        }

        container.register(EditViewModelFactory.self) { resolver in
            EditViewModelFactory(
                itemsRepository: resolver.resolve(ItemsRepository.self)!,
                photosRepository: resolver.resolve(PhotosRepository.self)!,
                fileService: resolver.resolve(FileService.self)!,
                statusNotifier: resolver.resolve(StatusNotifier.self)!,
                eventBus: resolver.resolve(EventBus.self)!
            )
        }
    }

    private func registerCoordinators(in container: Container) {
        container.register(AddCoordinator.self) { resolver in
            AddCoordinator(imagePickerFactory: resolver.resolve(ImagePickerControllerFactory.self)!)
        }

        container.register(EditCoordinator.self) { resolver in
            EditCoordinator(
                imagePickerFactory: resolver.resolve(ImagePickerControllerFactory.self)!,
                moveItemViewModelFactory: resolver.resolve(MoveItemViewModelFactory.self)!
            )
        }

        container.register(ItemsCoordinator.self) { resolver in
            ItemsCoordinator(
                sharingControllerFactory: resolver.resolve(SharingControllerFactory.self)!,
                addViewModelFactory: resolver.resolve(AddViewModelFactory.self)!,
                editViewModelFactory: resolver.resolve(EditViewModelFactory.self)!,
                moveItemViewModelFactory: resolver.resolve(MoveItemViewModelFactory.self)!,
                addCoordinator: resolver.resolve(AddCoordinator.self)!,
                editCoordinator: resolver.resolve(EditCoordinator.self)!
            )
        }

        container.register(ListsCoordinator.self) { resolver in
            ListsCoordinator(
                itemsViewModelFactory: resolver.resolve(ItemsViewModelFactory.self)!,
                itemsCoordinator: resolver.resolve(ItemsCoordinator.self)!
            )
        }
    }

    private func registerViewControllerFactories(in container: Container, with configuration: Configuration) {
        container.register(ImagePickerControllerFactory.self) { _ in
            ImagePickerControllerFactory()
        }

        container.register(ListsViewControllerFactory.self) { resolver in
            ListsViewControllerFactory(
                viewModelFactory: resolver.resolve(ListsViewModelFactory.self)!,
                notificationCenter: resolver.resolve(NotificationCenter.self)!,
                listsCoordinator: resolver.resolve(ListsCoordinator.self)!
            )
        }
    }
}

internal extension DependencyContainer {
    enum Configuration {
        case inMemory
        case cloudKit(containerIdentifier: String)
    }
}
