import UIKit

public final class ItemsViewControllerFactory {
    private let viewModel: ItemsViewModel
    private let coordinator: ItemsCoordinator

    public init(viewModel: ItemsViewModel, coordinator: ItemsCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator
    }

    public func create(for list: List) -> UIViewController {
        viewModel.set(list)

        return ItemsNavigationController(
            rootViewController: ItemsViewController(
                viewModel: viewModel,
                coordinator: coordinator
            )
        )
    }
}
