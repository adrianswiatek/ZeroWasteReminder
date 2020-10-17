import Swinject
import UserNotifications

public final class GeneralDependencyResolver: DependencyResolver {
    private let container: Container

    public init(_ container: Container) {
        self.container = container
    }

    public func registerCoordinators() {
        container.register(AddCoordinator.self) { resolver in
            AddCoordinator(
                imagePickerFactory: resolver.resolve(ImagePickerControllerFactory.self)!,
                eventDispatcher: resolver.resolve(EventDispatcher.self)!
            )
        }

        container.register(EditCoordinator.self) { resolver in
            EditCoordinator(
                imagePickerFactory: resolver.resolve(ImagePickerControllerFactory.self)!,
                moveItemViewModelFactory: resolver.resolve(MoveItemViewModelFactory.self)!,
                eventDispatcher: resolver.resolve(EventDispatcher.self)!
            )
        }

        container.register(ItemsCoordinator.self) { resolver in
            ItemsCoordinator(
                sharingControllerFactory: resolver.resolve(SharingControllerFactory.self)!,
                addViewModelFactory: resolver.resolve(AddItemViewModelFactory.self)!,
                editViewModelFactory: resolver.resolve(EditItemViewModelFactory.self)!,
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
        container.register(UpdateListsDate.self) { resolver in
            UpdateListsDate(
                resolver.resolve(ListsRepository.self)!,
                resolver.resolve(EventDispatcher.self)!
            )
        }

        container.register(ScheduleItemNotification.self) { resolver in
            ScheduleItemNotification(
                resolver.resolve(ItemNotificationScheduler.self)!,
                resolver.resolve(EventDispatcher.self)!
            )
        }
    }

    public func registerOtherObjects() {
        container.register(NotificationCenter.self) { _ in
            NotificationCenter.default
        }.inObjectScope(.container)

        container.register(UNUserNotificationCenter.self) { _ in
            UNUserNotificationCenter.current()
        }.inObjectScope(.container)

        container.register(EventDispatcher.self) { resolver in
            EventDispatcher()
        }.inObjectScope(.container)

        container.register(EventDispatcherInterceptor.self) { resolver in
            ConsoleEventDispatcherInterceptor(eventDispatcher: resolver.resolve(EventDispatcher.self)!)
        }

        container.register(RemoteNotificationHandler.self) { resolver in
            RemoteNotificationHandler(eventDispatcher: resolver.resolve(EventDispatcher.self)!)
        }

        container.register(ItemNotificationRequestFactory.self) { resolver in
            CalendarItemNotificationRequestFactory()
        }

        container.register(ItemUserNotificationScheduler.self) { resolver in
            ItemUserNotificationScheduler(
                userNotificationRequestFactory: resolver.resolve(ItemNotificationRequestFactory.self)!,
                notificationRepository: resolver.resolve(ItemNotificationsRepository.self)!,
                userNotificationCenter: resolver.resolve(UNUserNotificationCenter.self)!,
                eventDispatcher: resolver.resolve(EventDispatcher.self)!
            )
        }

        container.register(ItemNotificationScheduler.self) { resolver in
            ConsoleItemNotificationSchedulerInterceptor(
                notificationScheduler: resolver.resolve(ItemUserNotificationScheduler.self)!,
                userNotificationCenter: resolver.resolve(UNUserNotificationCenter.self)!
            )
        }

        container.register(StatusNotifier.self) { resolver in
            RemoteStatusNotifier(accountService: resolver.resolve(AccountService.self)!)
        }.inObjectScope(.container)
    }

    public func registerRepositories() {
        container.register(ItemNotificationsRepository.self) { _ in
//            InMemoryNotificationsRepository()
            CoreDataItemNotificationsRepository(coreDataStack: CoreDataStack())
        }.inObjectScope(.container)
    }

    public func registerServices() {
        container.register(FileService.self) { _ in
            FileService(fileManager: .default)
        }

        container.register(MoveItemService.self) { resolver in
            DefaultMoveItemService(
                listsRepository: resolver.resolve(ListsRepository.self)!,
                itemsWriteRepository: resolver.resolve(ItemsWriteRepository.self)!,
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
                itemsReadRepository: resolver.resolve(ItemsReadRepository.self)!,
                itemsWriteRepository: resolver.resolve(ItemsWriteRepository.self)!,
                statusNotifier: resolver.resolve(StatusNotifier.self)!,
                updateListsDate: resolver.resolve(UpdateListsDate.self)!,
                eventDispatcher: resolver.resolve(EventDispatcher.self)!
            )
        }

        container.register(MoveItemViewModelFactory.self) { resolver in
            MoveItemViewModelFactory(
                moveItemService: resolver.resolve(MoveItemService.self)!,
                eventDispatcher: resolver.resolve(EventDispatcher.self)!
            )
        }

        container.register(AddItemViewModelFactory.self) { resolver in
            AddItemViewModelFactory(
                itemsWriteRepository: resolver.resolve(ItemsWriteRepository.self)!,
                photosRepository: resolver.resolve(PhotosRepository.self)!,
                fileService: resolver.resolve(FileService.self)!,
                statusNotifier: resolver.resolve(StatusNotifier.self)!,
                eventDispatcher: resolver.resolve(EventDispatcher.self)!
            )
        }

        container.register(EditItemViewModelFactory.self) { resolver in
            EditItemViewModelFactory(
                itemsReadRepository: resolver.resolve(ItemsReadRepository.self)!,
                itemsWriteRepository: resolver.resolve(ItemsWriteRepository.self)!,
                photosRepository: resolver.resolve(PhotosRepository.self)!,
                fileService: resolver.resolve(FileService.self)!,
                statusNotifier: resolver.resolve(StatusNotifier.self)!,
                eventDispatcher: resolver.resolve(EventDispatcher.self)!
            )
        }
    }
}
