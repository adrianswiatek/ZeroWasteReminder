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

    public func registerEventListeners() {
        container.register(ListsChangeListener.self) { resolver in
            ListsChangeListener(
                resolver.resolve(ListsRepository.self)!,
                resolver.resolve(EventDispatcher.self)!
            )
        }.inObjectScope(.container)

        container.register(ItemsChangeListener.self) { resolver in
            ItemsChangeListener(
                resolver.resolve(ListsRepository.self)!,
                resolver.resolve(EventDispatcher.self)!
            )
        }.inObjectScope(.container)
    }

    public func registerOtherObjects() {
        container.register(NotificationCenter.self) { _ in
            NotificationCenter.default
        }

        container.register(EventDispatcher.self) { resolver in
            EventDispatcher()
        }.inObjectScope(.container)

        container.register(EventDispatcherInterceptor.self) { resolver in
            ConsoleeventDispatcherInterceptor(resolver.resolve(EventDispatcher.self)!)
        }.inObjectScope(.container)

        container.register(RemoteNotificationHandler.self) { resolver in
            RemoteNotificationHandler(eventDispatcher: resolver.resolve(EventDispatcher.self)!)
        }

        container.register(StatusNotifier.self) { resolver in
            RemoteStatusNotifier(accountService: resolver.resolve(AccountService.self)!)
        }.inObjectScope(.container)
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
                eventDispatcher: resolver.resolve(EventDispatcher.self)!
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
                statusNotifier: resolver.resolve(StatusNotifier.self)!,
                eventDispatcher: resolver.resolve(EventDispatcher.self)!
            )
        }

        container.register(ItemsViewModelFactory.self) { resolver in
            ItemsViewModelFactory(
                itemsRepository: resolver.resolve(ItemsRepository.self)!,
                statusNotifier: resolver.resolve(StatusNotifier.self)!,
                itemsChangeListener: resolver.resolve(ItemsChangeListener.self)!,
                eventDispatcher: resolver.resolve(EventDispatcher.self)!
            )
        }

        container.register(MoveItemViewModelFactory.self) { resolver in
            MoveItemViewModelFactory(
                moveItemService: resolver.resolve(MoveItemService.self)!,
                eventDispatcher: resolver.resolve(EventDispatcher.self)!
            )
        }

        container.register(AddViewModelFactory.self) { resolver in
            AddViewModelFactory(
                itemsRepository: resolver.resolve(ItemsRepository.self)!,
                photosRepository: resolver.resolve(PhotosRepository.self)!,
                fileService: resolver.resolve(FileService.self)!,
                statusNotifier: resolver.resolve(StatusNotifier.self)!,
                eventDispatcher: resolver.resolve(EventDispatcher.self)!
            )
        }

        container.register(EditViewModelFactory.self) { resolver in
            EditViewModelFactory(
                itemsRepository: resolver.resolve(ItemsRepository.self)!,
                photosRepository: resolver.resolve(PhotosRepository.self)!,
                fileService: resolver.resolve(FileService.self)!,
                statusNotifier: resolver.resolve(StatusNotifier.self)!,
                eventDispatcher: resolver.resolve(EventDispatcher.self)!
            )
        }
    }
}
