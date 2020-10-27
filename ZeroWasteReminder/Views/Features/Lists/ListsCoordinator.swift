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

    public func navigateToItems(with list: List, in viewController: UIViewController) {
        let itemsViewController = itemsViewControllerFactory.create(for: list)
        itemsViewController.modalPresentationStyle = .fullScreen
        viewController.present(itemsViewController, animated: true)
    }

    public func navigateToSearch(in viewController: UIViewController) {
        let searchViewController = searchViewControllerFactory.create()
        searchViewController.modalPresentationStyle = .fullScreen
        viewController.present(searchViewController, animated: true)
    }
}
