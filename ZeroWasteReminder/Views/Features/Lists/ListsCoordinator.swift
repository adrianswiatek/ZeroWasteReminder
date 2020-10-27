import UIKit

public final class ListsCoordinator {
    private let searchViewControllerFactory: SearchViewControllerFactory
    private let itemsViewControllerFactory: ItemsViewControllerFactory
    private let itemsCoordinator: ItemsCoordinator

    public init(
        searchViewControllerFactory: SearchViewControllerFactory,
        itemsViewControllerFactory: ItemsViewControllerFactory,
        itemsCoordinator: ItemsCoordinator
    ) {
        self.searchViewControllerFactory = searchViewControllerFactory
        self.itemsViewControllerFactory = itemsViewControllerFactory
        self.itemsCoordinator = itemsCoordinator
    }

    public func navigateToSearch(in viewController: UIViewController) {
        viewController.present(searchViewControllerFactory.create(), animated: true)
    }

    public func navigateToItems(with list: List, in viewController: UIViewController) {
        viewController.present(itemsViewControllerFactory.create(for: list), animated: true)
    }
}
