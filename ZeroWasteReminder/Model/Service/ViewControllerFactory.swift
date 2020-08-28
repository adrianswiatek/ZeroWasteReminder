import UIKit

public final class ViewControllerFactory {
    private let fileService: FileService
    private let moveItemService: MoveItemService

    private let itemsRepository: ItemsRepository
    private let listsRepository: ListsRepository
    private let photosRepository: PhotosRepository

    private let listUpdater: AutomaticListsUpdater
    private let statusNotifier: StatusNotifier
    private let sharingControllerFactory: SharingControllerFactory
    private let notificationCenter: NotificationCenter

    public init(
        fileService: FileService,
        moveItemService: MoveItemService,
        itemsRepository: ItemsRepository,
        listsRepository: ListsRepository,
        photosRepository: PhotosRepository,
        listUpdater: AutomaticListsUpdater,
        statusNotifier: StatusNotifier,
        sharingControllerFactory: SharingControllerFactory,
        notificationCenter: NotificationCenter
    ) {
        self.fileService = fileService
        self.moveItemService = moveItemService

        self.itemsRepository = itemsRepository
        self.listsRepository = listsRepository
        self.photosRepository = photosRepository

        self.listUpdater = listUpdater
        self.statusNotifier = statusNotifier
        self.sharingControllerFactory = sharingControllerFactory
        self.notificationCenter = notificationCenter
    }

    public var listsViewController: UIViewController {
        ListsNavigationController(rootViewController: ListsViewController(
            viewModel: .init(listsRepository: listsRepository, statusNotifier: statusNotifier),
            factory: self,
            notificationCenter: notificationCenter
        ))
    }

    public func itemsViewController(for list: List) -> UIViewController {
        let viewModel = ItemsViewModel(
            list: list,
            itemsRepository: itemsRepository,
            listsUpdater: listUpdater,
            statusNotifier: statusNotifier
        )
        let viewController = ItemsViewController(viewModel: viewModel, factory: self)
        return ItemsNavigationController(rootViewController: viewController)
    }

    public func addViewController(for list: List) -> UIViewController {
        let viewModel = AddViewModel(
            list: list,
            itemsRepository: itemsRepository,
            photosRepository: photosRepository,
            fileService: fileService,
            statusNotifier: statusNotifier
        )
        let viewController = AddViewController(viewModel: viewModel, factory: self)
        return AddNavigationController(rootViewController: viewController)
    }

    public func editViewController(for item: Item) -> UIViewController {
        let viewModel = EditViewModel(
            item: item,
            itemsRepository: itemsRepository,
            photosRepository: photosRepository,
            fileService: fileService,
            statusNotifier: statusNotifier
        )
        return EditViewController(viewModel: viewModel, factory: self)
    }

    public var sharingController: UIViewController {
        sharingControllerFactory.build()
    }

    public func imagePickerController(
        for target: PhotoCaptureTarget,
        with delegate: UIImagePickerControllerDelegate & UINavigationControllerDelegate
    ) -> UIImagePickerController? {
        let sourceType: UIImagePickerController.SourceType = .fromPhotoCaptureTarget(target)
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else { return nil }

        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = sourceType
        imagePickerController.mediaTypes = ["public.image"]
        imagePickerController.delegate = delegate
        return imagePickerController
    }

    public func moveItemViewController(item: Item) -> UIViewController {
        let viewModel = MoveItemViewModel(item: item, moveItemService: moveItemService)
        let viewController = MoveItemViewController(viewModel: viewModel)
        return MoveItemNavigationController(rootViewController: viewController)
    }
}
