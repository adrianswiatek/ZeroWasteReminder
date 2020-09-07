import UIKit
import Swinject

internal final class DependencyContainer {
    private let container: Container

    init(configuration: Configuration) {
        container = Container()

        registerServices(in: container, with: configuration)
        registerRepositories(in: container, with: configuration)
        registerOtherObjects(in: container, with: configuration)
        registerViewControllerFactories(in: container, with: configuration)
        registerViewModelFactories(in: container)
        registerCoordinators(in: container)
    }

    public var rootViewController: UIViewController {
        container.resolve(ListsViewControllerFactory.self)!.create()
    }

    public func initializeBackgroundServices() {
        container.resolve(AccountService.self)!.refreshUserEligibility()
        container.resolve(SubscriptionService.self)!.registerItemsSubscriptionIfNeeded()
        container.resolve(AutomaticListUpdater.self)!.startUpdating()
    }

    private func registerServices(in container: Container, with configuration: Configuration) {
        container.register(FileService.self) { _ in
            FileService(fileManager: .default)
        }.inObjectScope(.container)

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
                itemsRepository: resolver.resolve(ItemsRepository.self)!
            )
        }.inObjectScope(.container)
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
                    mapper: resolver.resolve(CloudKitMapper.self)!
                )
            case .inMemory:
                return InMemoryListsRepository()
            }
        }.inObjectScope(.container)

        container.register(ItemsRepository.self) { resolver in
            switch configuration {
            case .cloudKit:
                return CloudKitItemsRepository(
                    configuration: resolver.resolve(CloudKitConfiguration.self)!,
                    cache: resolver.resolve(CloudKitCache.self)!,
                    mapper: resolver.resolve(CloudKitMapper.self)!
                )
            case .inMemory:
                return InMemoryItemsRepository()
            }
        }.inObjectScope(.container)

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

        container.register(NotificationCenter.self) { _ in
            NotificationCenter.default
        }

        container.register(StatusNotifier.self) { resolver in
            RemoteStatusNotifier(accountService: resolver.resolve(AccountService.self)!)
        }.inObjectScope(.container)

        container.register(ListItemsChangeListener.self) { resolver in
            DefaultListItemsChangeListener(
                itemsRepository: resolver.resolve(ItemsRepository.self)!,
                moveItemService: resolver.resolve(MoveItemService.self)!
            )
        }.inObjectScope(.container)

        container.register(AutomaticListUpdater.self) { resolver in
            AutomaticListUpdater(
                resolver.resolve(ListsRepository.self)!,
                resolver.resolve(ListItemsChangeListener.self)!
            )
        }.inObjectScope(.container)
    }

    private func registerViewModelFactories(in container: Container) {
        container.register(ListsViewModelFactory.self) { resolver in
            ListsViewModelFactory(
                listsRepository: resolver.resolve(ListsRepository.self)!,
                statusNotifier: resolver.resolve(StatusNotifier.self)!
            )
        }

        container.register(ItemsViewModelFactory.self) { resolver in
            ItemsViewModelFactory(
                itemsRepository: resolver.resolve(ItemsRepository.self)!,
                listItemsChangeListener: resolver.resolve(ListItemsChangeListener.self)!,
                statusNotifier: resolver.resolve(StatusNotifier.self)!
            )
        }

        container.register(MoveItemViewModelFactory.self) { resolver in
            MoveItemViewModelFactory(moveItemService: resolver.resolve(MoveItemService.self)!)
        }

        container.register(AddViewModelFactory.self) { resolver in
            AddViewModelFactory(
                itemsRepository: resolver.resolve(ItemsRepository.self)!,
                photosRepository: resolver.resolve(PhotosRepository.self)!,
                fileService: resolver.resolve(FileService.self)!,
                statusNotifier: resolver.resolve(StatusNotifier.self)!
            )
        }

        container.register(EditViewModelFactory.self) { resolver in
            EditViewModelFactory(
                itemsRepository: resolver.resolve(ItemsRepository.self)!,
                photosRepository: resolver.resolve(PhotosRepository.self)!,
                fileService: resolver.resolve(FileService.self)!,
                statusNotifier: resolver.resolve(StatusNotifier.self)!
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
