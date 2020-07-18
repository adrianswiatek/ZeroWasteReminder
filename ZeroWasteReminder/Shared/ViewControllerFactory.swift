import UIKit

public final class ViewControllerFactory {
    private let itemsService: ItemsService
    private let fileService: FileService

    private let itemsRepository: ItemsRepository
    private let listsRepository: ListsRepository
    private let photosRepository: PhotosRepository

    private let remoteStatusNotifier: RemoteStatusNotifier
    private let sharingControllerFactory: SharingControllerFactory
    private let notificationCenter: NotificationCenter

    public init(
        itemsService: ItemsService,
        photosRepository: PhotosRepository,
        fileService: FileService,
        itemsRepository: ItemsRepository,
        listsRepository: ListsRepository,
        remoteStatusNotifier: RemoteStatusNotifier,
        sharingControllerFactory: SharingControllerFactory,
        notificationCenter: NotificationCenter
    ) {
        self.itemsService = itemsService
        self.photosRepository = photosRepository
        self.fileService = fileService

        self.itemsRepository = itemsRepository
        self.listsRepository = listsRepository

        self.remoteStatusNotifier = remoteStatusNotifier
        self.sharingControllerFactory = sharingControllerFactory
        self.notificationCenter = notificationCenter
    }

    public var listsViewController: UIViewController {
        ListsNavigationController(rootViewController: ListsViewController(
            viewModel: .init(listsRepository: listsRepository),
            factory: self,
            notificationCenter: notificationCenter
        ))
    }

    public var listViewController: UIViewController {
        let viewModel = ItemsListViewModel(
            itemsService: itemsService,
            itemsRepository: itemsRepository,
            remoteStatusNotifier: remoteStatusNotifier
        )
        let viewController = ItemsListViewController(viewModel: viewModel, factory: self)
        return ItemsListNavigationController(rootViewController: viewController)
    }

    public var addViewController: UIViewController {
        let viewModel = AddViewModel(
            itemsService: itemsService,
            photosRepository: photosRepository,
            fileService: fileService,
            remoteStatusNotifier: remoteStatusNotifier
        )
        let viewController = AddViewController(viewModel: viewModel, factory: self)
        return AddNavigationController(rootViewController: viewController)
    }

    public func editViewController(for item: Item) -> UIViewController {
        let viewModel = EditViewModel(
            item: item,
            itemsService: itemsService,
            photosRepository: photosRepository,
            fileService: fileService,
            remoteStatusNotifier: remoteStatusNotifier
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
}
