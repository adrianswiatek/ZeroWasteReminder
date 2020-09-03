import UIKit
import Swinject

internal final class DependencyContainer {
    private let container: Container

    init(configuration: Configuration) {
        container = Container()

        registerServices(in: container)
        registerRepositories(in: container)
        registerOtherObjects(in: container, with: configuration)
        registerCoordinators(in: container)
        registerViewModelFactories(in: container)
        registerViewControllerFactories(in: container)
    }

    public var rootViewController: UIViewController {
        container.resolve(ListsViewControllerFactory.self)!.create()
    }

    public func initializeServices() {
        container.resolve(AccountService.self)!.refreshUserEligibility()
        container.resolve(SubscriptionService.self)!.registerItemsSubscriptionIfNeeded()
    }

    private func registerServices(in container: Container) {
        container.register(FileService.self) { _ in
            FileService(fileManager: .default)
        }.inObjectScope(.container)

        container.register(AccountService.self) { resolver in
            resolver.resolve(VariableDependenciesFactory.self)!.accountService
        }

        container.register(SubscriptionService.self) { resolver in
            resolver.resolve(VariableDependenciesFactory.self)!.subscriptionService
        }

        container.register(MoveItemService.self) { resolver in
            DefaultMoveItemService(
                listsRepository: resolver.resolve(ListsRepository.self)!,
                itemsRepository: resolver.resolve(ItemsRepository.self)!
            )
        }
    }

    private func registerRepositories(in container: Container) {
        container.register(InMemoryCloudKitCache.self) { _ in
            InMemoryCloudKitCache()
        }.inObjectScope(.transient)

        container.register(CloudKitMapper.self) { resolver in
            CloudKitMapper(fileService: resolver.resolve(FileService.self)!)
        }

        container.register(ListsRepository.self) { resolver in
            resolver.resolve(VariableDependenciesFactory.self)!.listsRepository
        }

        container.register(ItemsRepository.self) { resolver in
            resolver.resolve(VariableDependenciesFactory.self)!.itemsRepository
        }

        container.register(PhotosRepository.self) { resolver in
            resolver.resolve(VariableDependenciesFactory.self)!.photosRepository
        }
    }

    private func registerOtherObjects(in container: Container, with configuration: Configuration) {
        container.register(VariableDependenciesFactory.self) { resolver in
            switch configuration {
            case .inMemory:
                return InMemoryVariableDependenciesFactory()
            case .cloudKit(let containerIdentifier):
                return CloudKitVariableDependenciesFactory(
                    configuration: CloudKitConfiguration(containerIdentifier: containerIdentifier),
                    itemsCache: resolver.resolve(InMemoryCloudKitCache.self)!,
                    listsCache: resolver.resolve(InMemoryCloudKitCache.self)!,
                    mapper: resolver.resolve(CloudKitMapper.self)!,
                    notificationCenter: resolver.resolve(NotificationCenter.self)!
                )
            }
        }.inObjectScope(.container)

        container.register(NotificationCenter.self) { _ in
            NotificationCenter.default
        }

        container.register(StatusNotifier.self) { resolver in
            resolver.resolve(VariableDependenciesFactory.self)!.statusNotifier
        }

        container.register(ListsChangeListener.self) { resolver in
            DefaultListsChangeListener(
                itemsRepository: resolver.resolve(ItemsRepository.self)!,
                moveItemService: resolver.resolve(MoveItemService.self)!
            )
        }
    }

    private func registerViewModelFactories(in container: Container) {
        container.register(ListsViewModelFactory.self) { resolver in
            ListsViewModelFactory(
                listsRepository: resolver.resolve(ListsRepository.self)!,
                listsChangeListener: resolver.resolve(ListsChangeListener.self)!,
                statusNotifier: resolver.resolve(StatusNotifier.self)!
            )
        }

        container.register(ItemsViewModelFactory.self) { resolver in
            ItemsViewModelFactory(
                itemsRepository: resolver.resolve(ItemsRepository.self)!,
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

    private func registerViewControllerFactories(in container: Container) {
        container.register(ImagePickerControllerFactory.self) { _ in
            ImagePickerControllerFactory()
        }

        container.register(SharingControllerFactory.self) { resolver in
            resolver.resolve(VariableDependenciesFactory.self)!.sharingControllerFactory
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
