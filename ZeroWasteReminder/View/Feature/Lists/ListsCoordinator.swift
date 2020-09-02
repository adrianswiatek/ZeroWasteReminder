import UIKit

public final class ListsCoordinator {
    private let itemsViewModelFactory: ItemsViewModelFactory
    private let itemsCoordinator: ItemsCoordinator

    public init(itemsViewModelFactory: ItemsViewModelFactory, itemsCoordinator: ItemsCoordinator) {
        self.itemsViewModelFactory = itemsViewModelFactory
        self.itemsCoordinator = itemsCoordinator
    }

    public func navigateToItems(with list: List, in viewController: UIViewController) {
        viewController.present(createItemsViewController(for: list), animated: true)
    }

    private func createItemsViewController(for list: List) -> UIViewController {
        let viewModel = itemsViewModelFactory.create(for: list)
        let viewController = ItemsViewController(viewModel: viewModel, coordinator: itemsCoordinator)
        return ItemsNavigationController(rootViewController: viewController)
    }
}
