import UIKit

public final class ViewControllerFactory {
    private let itemsService: ItemsService

    public init(itemsService: ItemsService) {
        self.itemsService = itemsService
    }

    public var listViewController: UIViewController {
        let viewModel = ItemsListViewModel(itemsService: itemsService)
        let viewController = ItemsListViewController(viewModel: viewModel, factory: self)
        return ItemsListNavigationController(rootViewController: viewController)
    }

    public var addViewController: UIViewController {
        let viewModel = AddViewModel(itemsService: itemsService)
        let viewController = AddViewController(viewModel: viewModel)
        return AddNavigationController(rootViewController: viewController)
    }

    public func editViewController(item: Item) -> UIViewController {
        let viewModel = EditViewModel(item: item, itemsService: itemsService)
        return EditViewController(viewModel: viewModel)
    }
}
