import Swinject
import UserNotifications

internal struct GeneralDependenciesRecorder: DependenciesRecorder {
    private let container: Container

    internal init(_ container: Container) {
        self.container = container
    }

    internal func register() {
        registerCoordinators()
        registerEventListeners()
        registerOtherObjects()
        registerServices()
        registerViewModels()
        registerViewControllerFactories()
    }

    private func registerCoordinators() {
        container.register(AddItemCoordinator.self) { resolver in
            AddItemCoordinator(
                imagePickerFactory: resolver.resolve(ImagePickerControllerFactory.self)!,
                eventDispatcher: resolver.resolve(EventDispatcher.self)!
            )
        }

        container.register(EditItemCoordinator.self) { resolver in
            EditItemCoordinator(
                imagePickerFactory: resolver.resolve(ImagePickerControllerFactory.self)!,
                moveItemViewControllerFactory: resolver.resolve(MoveItemViewControllerFactory.self)!,
                eventDispatcher: resolver.resolve(EventDispatcher.self)!
            )
        }

        container.register(ItemsCoordinator.self) { resolver in
            ItemsCoordinator(
                sharingControllerFactory: resolver.resolve(SharingControllerFactory.self)!,
                addItemViewControllerFactory: resolver.resolve(AddItemViewControllerFactory.self)!,
                editItemViewControllerFactory: resolver.resolve(EditItemViewControllerFactory.self)!,
                moveItemViewControllerFactory: resolver.resolve(MoveItemViewControllerFactory.self)!,
                addCoordinator: resolver.resolve(AddItemCoordinator.self)!,
                editCoordinator: resolver.resolve(EditItemCoordinator.self)!
            )
        }

        container.register(ListsCoordinator.self) { resolver in
            ListsCoordinator(
                searchViewControllerFactory: resolver.resolve(SearchViewControllerFactory.self)!,
                itemsViewControllerFactory: resolver.resolve(ItemsViewControllerFactory.self)!,
                itemsCoordinator: resolver.resolve(ItemsCoordinator.self)!
            )
        }
    }

    private func registerEventListeners() {
        container.register(UpdateListsDate.self) { resolver in
            UpdateListsDate(
                resolver.resolve(ListsRepository.self)!,
                resolver.resolve(EventDispatcher.self)!
            )
        }

        container.register(ScheduleItemNotification.self) { resolver in
            ScheduleItemNotification(
                resolver.resolve(ItemNotificationsScheduler.self)!,
                resolver.resolve(EventDispatcher.self)!
            )
        }
    }

    private func registerOtherObjects() {
        container.register(NotificationCenter.self) { _ in
            .default
        }.inObjectScope(.container)

        container.register(UNUserNotificationCenter.self) { _ in
            .current()
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

        container.register(ItemNotificationsScheduler.self) { resolver in
            ItemUserNotificationScheduler(
                userNotificationRequestFactory: resolver.resolve(ItemNotificationRequestFactory.self)!,
                notificationRepository: resolver.resolve(ItemNotificationsRepository.self)!,
                userNotificationCenter: resolver.resolve(UNUserNotificationCenter.self)!,
                eventDispatcher: resolver.resolve(EventDispatcher.self)!
            )
        }

        container.register(StatusNotifier.self) { resolver in
            RemoteStatusNotifier(accountService: resolver.resolve(AccountService.self)!)
        }.inObjectScope(.container)
    }

    private func registerServices() {
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

        container.register(ItemNotificationsRescheduler.self) { resolver in
            ItemUserNotificationsResheduler(
                itemNotificationsRepository: resolver.resolve(ItemNotificationsRepository.self)!,
                notificationRequestFactory: resolver.resolve(ItemNotificationRequestFactory.self)!,
                userNotificationCenter: resolver.resolve(UNUserNotificationCenter.self)!
            )
        }
    }

    private func registerViewModels() {
        container.register(ListsViewModel.self) { resolver in
            ListsViewModel(
                listsRepository: resolver.resolve(ListsRepository.self)!,
                statusNotifier: resolver.resolve(StatusNotifier.self)!,
                eventDispatcher: resolver.resolve(EventDispatcher.self)!
            )
        }

        container.register(ItemsViewModel.self) { resolver in
            ItemsViewModel(
                itemsReadRepository: resolver.resolve(ItemsReadRepository.self)!,
                itemsWriteRepository: resolver.resolve(ItemsWriteRepository.self)!,
                statusNotifier: resolver.resolve(StatusNotifier.self)!,
                updateListsDate: resolver.resolve(UpdateListsDate.self)!,
                eventDispatcher: resolver.resolve(EventDispatcher.self)!
            )
        }

        container.register(AddItemViewModel.self) { resolver in
            AddItemViewModel(
                itemsWriteRepository: resolver.resolve(ItemsWriteRepository.self)!,
                photosRepository: resolver.resolve(PhotosRepository.self)!,
                fileService: resolver.resolve(FileService.self)!,
                statusNotifier: resolver.resolve(StatusNotifier.self)!,
                eventDispatcher: resolver.resolve(EventDispatcher.self)!
            )
        }

        container.register(EditItemViewModel.self) { resolver in
            EditItemViewModel(
                itemsReadRepository: resolver.resolve(ItemsReadRepository.self)!,
                itemsWriteRepository: resolver.resolve(ItemsWriteRepository.self)!,
                photosRepository: resolver.resolve(PhotosRepository.self)!,
                fileService: resolver.resolve(FileService.self)!,
                statusNotifier: resolver.resolve(StatusNotifier.self)!,
                eventDispatcher: resolver.resolve(EventDispatcher.self)!
            )
        }

        container.register(MoveItemViewModel.self) { resolver in
            MoveItemViewModel(
                moveItemService: resolver.resolve(MoveItemService.self)!,
                statusNotifier: resolver.resolve(StatusNotifier.self)!,
                eventDispatcher: resolver.resolve(EventDispatcher.self)!
            )
        }

        container.register(SearchViewModel.self) { resolver in
            SearchViewModel(
                listsRepository: resolver.resolve(ListsRepository.self)!,
                itemsRepository: resolver.resolve(ItemsReadRepository.self)!
            )
        }
    }

    private func registerViewControllerFactories() {
        container.register(ListsViewControllerFactory.self) { resolver in
            ListsViewControllerFactory(
                viewModel: resolver.resolve(ListsViewModel.self)!,
                notificationCenter: resolver.resolve(NotificationCenter.self)!,
                listsCoordinator: resolver.resolve(ListsCoordinator.self)!
            )
        }

        container.register(ItemsViewControllerFactory.self) { resolver in
            ItemsViewControllerFactory(
                viewModel: resolver.resolve(ItemsViewModel.self)!,
                coordinator: resolver.resolve(ItemsCoordinator.self)!
            )
        }

        container.register(AddItemViewControllerFactory.self) { resolver in
            AddItemViewControllerFactory(
                viewModel: resolver.resolve(AddItemViewModel.self)!,
                coordinator: resolver.resolve(AddItemCoordinator.self)!
            )
        }

        container.register(EditItemViewControllerFactory.self) { resolver in
            EditItemViewControllerFactory(
                viewModel: resolver.resolve(EditItemViewModel.self)!,
                coordinator: resolver.resolve(EditItemCoordinator.self)!
            )
        }

        container.register(MoveItemViewControllerFactory.self) { resolver in
            MoveItemViewControllerFactory(viewModel: resolver.resolve(MoveItemViewModel.self)!)
        }

        container.register(SearchViewControllerFactory.self) { resolver in
            SearchViewControllerFactory(viewModel: resolver.resolve(SearchViewModel.self)!)
        }

        container.register(ImagePickerControllerFactory.self) { _ in
            ImagePickerControllerFactory()
        }

        container.register(SharingControllerFactory.self) { _ in
            EmptySharingControllerFactory()
        }
    }
}
