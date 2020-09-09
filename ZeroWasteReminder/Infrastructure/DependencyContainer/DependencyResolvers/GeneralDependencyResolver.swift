import Swinject

public final class GeneralDependencyResolver: DependencyResolver {
    private let container: Container

    public init(_ container: Container) {
        self.container = container
    }

    public func registerCoordinators() {
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

    public func registerOtherObjects() {
        container.register(NotificationCenter.self) { _ in
            NotificationCenter.default
        }

        container.register(EventBus.self) { _ in
            EventBus()
        }.inObjectScope(.container)

        container.register(EventBusInterceptor.self) { resolver in
            ConsoleEventBusInterceptor(resolver.resolve(EventBus.self)!)
        }.inObjectScope(.container)

        container.register(StatusNotifier.self) { resolver in
            RemoteStatusNotifier(accountService: resolver.resolve(AccountService.self)!)
        }.inObjectScope(.container)

        container.register(AutomaticListUpdater.self) { resolver in
            DefaultAutomaticListUpdater(
                resolver.resolve(ListsRepository.self)!,
                resolver.resolve(EventBus.self)!
            )
        }
    }

    public func registerRepositories() {}

    public func registerServices() {
        container.register(FileService.self) { _ in
            FileService(fileManager: .default)
        }

        container.register(MoveItemService.self) { resolver in
            DefaultMoveItemService(
                listsRepository: resolver.resolve(ListsRepository.self)!,
                itemsRepository: resolver.resolve(ItemsRepository.self)!,
                eventBus: resolver.resolve(EventBus.self)!
            )
        }
    }

    public func registerViewControllerFactories() {
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

        container.register(SharingControllerFactory.self) { _ in
            EmptySharingControllerFactory()
        }
    }

    public func registerViewModelFactories() {
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
}
