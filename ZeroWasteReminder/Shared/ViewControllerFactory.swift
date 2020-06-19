import UIKit

public final class ViewControllerFactory {
    private let itemsService: ItemsService
    private let remoteStatusNotifier: RemoteStatusNotifier
    private let sharingControllerFactory: SharingControllerFactory
    private let fileService: FileService

    public init(
        itemsService: ItemsService,
        remoteStatusNotifier: RemoteStatusNotifier,
        sharingControllerFactory: SharingControllerFactory,
        fileService: FileService
    ) {
        self.itemsService = itemsService
        self.remoteStatusNotifier = remoteStatusNotifier
        self.sharingControllerFactory = sharingControllerFactory
        self.fileService = fileService
    }

    public var listViewController: UIViewController {
        let viewModel = ItemsListViewModel(
            itemsService: itemsService,
            remoteStatusNotifier: remoteStatusNotifier
        )
        let viewController = ItemsListViewController(viewModel: viewModel, factory: self)
        return ItemsListNavigationController(rootViewController: viewController)
    }

    public var addViewController: UIViewController {
        let viewModel = AddViewModel(
            itemsService: itemsService,
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
            fileService: fileService,
            remoteStatusNotifier: remoteStatusNotifier
        )
        return EditViewController(viewModel: viewModel)
    }

    public var sharingController: UIViewController {
        sharingControllerFactory.build()
    }
}
