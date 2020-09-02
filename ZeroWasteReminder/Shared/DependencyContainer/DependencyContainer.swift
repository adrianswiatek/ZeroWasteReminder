import UIKit

internal final class DependencyContainer {
    internal let notificationCenter: NotificationCenter

    internal let fileService: FileService
    internal let moveItemService: DefaultMoveItemService
    internal let accountService: AccountService
    internal let subscriptionService: SubscriptionService

    internal let listsChangeListener: ListsChangeListener
    internal let statusNotifier: StatusNotifier

    internal let sharingControllerFactory: SharingControllerFactory
    internal let imagePickerControllerFactory: ImagePickerControllerFactory

    internal let listsRepository: ListsRepository
    internal let itemsRepository: ItemsRepository
    internal let photosRepository: PhotosRepository

    internal let listsViewModelFactory: ListsViewModelFactory
    internal let itemsViewModelFactory: ItemsViewModelFactory
    internal let moveItemViewModelFactory: MoveItemViewModelFactory
    internal let addViewModelFactory: AddViewModelFactory
    internal let editViewModelFactory: EditViewModelFactory

    internal let addCoordinator: AddCoordinator
    internal let editCoordinator: EditCoordinator
    internal let itemsCoordinator: ItemsCoordinator
    internal let listsCoordinator: ListsCoordinator

    init(configuration: Configuration) {
        self.notificationCenter = .default
        self.fileService = FileService(fileManager: .default)

        var variableDependenciesFactory: VariableDependenciesFactory

        switch configuration {
        case .inMemory:
            variableDependenciesFactory = InMemoryVariableDependenciesFactory()
        case .cloudKit(let containerIdentifier):
            variableDependenciesFactory = CloudKitVariableDependenciesFactory(
                configuration: CloudKitConfiguration(containerIdentifier: containerIdentifier),
                listsCache: InMemoryCloudKitCache(),
                fileService: fileService,
                notificationCenter: notificationCenter
            )
        }

        self.accountService = variableDependenciesFactory.accountService
        self.subscriptionService = variableDependenciesFactory.subscriptionService
        self.statusNotifier = variableDependenciesFactory.statusNotifier

        self.sharingControllerFactory = variableDependenciesFactory.sharingControllerFactory
        self.imagePickerControllerFactory = ImagePickerControllerFactory()

        self.listsRepository = variableDependenciesFactory.listsRepository
        self.itemsRepository = variableDependenciesFactory.itemsRepository
        self.photosRepository = variableDependenciesFactory.photosRepository

        self.moveItemService = DefaultMoveItemService(
            listsRepository: listsRepository,
            itemsRepository: itemsRepository
        )

        self.listsChangeListener = DefaultListsChangeListener(
            itemsRepository: itemsRepository,
            moveItemService: moveItemService
        )

        self.listsViewModelFactory = ListsViewModelFactory(
            listsRepository: listsRepository,
            listsChangeListener: listsChangeListener,
            statusNotifier: statusNotifier
        )

        self.itemsViewModelFactory = ItemsViewModelFactory(
            itemsRepository: itemsRepository,
            statusNotifier: statusNotifier
        )

        self.moveItemViewModelFactory = MoveItemViewModelFactory(
            moveItemService: moveItemService
        )

        self.addViewModelFactory = AddViewModelFactory(
            itemsRepository: itemsRepository,
            photosRepository: photosRepository,
            fileService: fileService,
            statusNotifier: statusNotifier
        )

        self.editViewModelFactory = EditViewModelFactory(
            itemsRepository: itemsRepository,
            photosRepository: photosRepository,
            fileService: fileService,
            statusNotifier: statusNotifier
        )

        self.addCoordinator = AddCoordinator(
            imagePickerFactory: imagePickerControllerFactory
        )

        self.editCoordinator = EditCoordinator(
            imagePickerFactory: imagePickerControllerFactory,
            moveItemViewModelFactory: moveItemViewModelFactory
        )

        self.itemsCoordinator = ItemsCoordinator(
            sharingControllerFactory: sharingControllerFactory,
            addViewModelFactory: addViewModelFactory,
            editViewModelFactory: editViewModelFactory,
            moveItemViewModelFactory: moveItemViewModelFactory,
            addCoordinator: addCoordinator,
            editCoordinator: editCoordinator
        )

        self.listsCoordinator = ListsCoordinator(
            itemsViewModelFactory: itemsViewModelFactory,
            itemsCoordinator: itemsCoordinator
        )
    }

    public lazy var rootViewController: UIViewController = {
        ListsViewControllerFactory(
            viewModelFactory: listsViewModelFactory,
            notificationCenter: notificationCenter,
            listsCoordinator: listsCoordinator
        ).create()
    }()
}

internal extension DependencyContainer {
    enum Configuration {
        case inMemory
        case cloudKit(containerIdentifier: String)
    }
}
