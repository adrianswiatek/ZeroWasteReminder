import UIKit

public final class ViewControllerFactory {
    private let itemsService: ItemsService
    private let photosService: PhotosService
    private let fileService: FileService

    private let itemsRepository: ItemsRepository
    private let remoteStatusNotifier: RemoteStatusNotifier
    private let sharingControllerFactory: SharingControllerFactory

    public init(
        itemsService: ItemsService,
        photosService: PhotosService,
        fileService: FileService,
        itemsRepository: ItemsRepository,
        remoteStatusNotifier: RemoteStatusNotifier,
        sharingControllerFactory: SharingControllerFactory
    ) {
        self.itemsService = itemsService
        self.photosService = photosService
        self.fileService = fileService

        self.itemsRepository = itemsRepository
        self.remoteStatusNotifier = remoteStatusNotifier
        self.sharingControllerFactory = sharingControllerFactory
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
            photosService: photosService,
            fileService: fileService,
            remoteStatusNotifier: remoteStatusNotifier
        )
        let viewController = AddViewController(viewModel: viewModel)
        return AddNavigationController(rootViewController: viewController)
    }

    public func editViewController(item: Item) -> UIViewController {
        let viewModel = EditViewModel(
            item: item,
            itemsService: itemsService,
            photosService: photosService,
            fileService: fileService,
            remoteStatusNotifier: remoteStatusNotifier
        )
        return EditViewController(viewModel: viewModel)
    }

    public var sharingController: UIViewController {
        sharingControllerFactory.build()
    }
}
