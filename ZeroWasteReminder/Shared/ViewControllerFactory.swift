import UIKit

public final class ViewControllerFactory {
    private let itemsService: ItemsService
    private let sharingControllerFactory: SharingControllerFactory
    private let fileService: FileService

    public init(
        itemsService: ItemsService,
        sharingControllerFactory: SharingControllerFactory,
        fileService: FileService
    ) {
        self.itemsService = itemsService
        self.sharingControllerFactory = sharingControllerFactory
        self.fileService = fileService
    }

    public var listViewController: UIViewController {
        let viewModel = ItemsListViewModel(itemsService: itemsService)
        let viewController = ItemsListViewController(viewModel: viewModel, factory: self)
        return ItemsListNavigationController(rootViewController: viewController)
    }

    public var addViewController: UIViewController {
        let viewModel = AddViewModel(itemsService: itemsService, fileService: fileService)
        let viewController = AddViewController(viewModel: viewModel)
        return AddNavigationController(rootViewController: viewController)
    }

    public func editViewController(item: Item) -> UIViewController {
        let viewModel = EditViewModel(item: item, itemsService: itemsService, fileService: fileService)
        return EditViewController(viewModel: viewModel)
    }

    public var sharingController: UIViewController {
        sharingControllerFactory.build()
    }
}
