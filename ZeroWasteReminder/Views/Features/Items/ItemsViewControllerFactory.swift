import UIKit

public final class ItemsViewControllerFactory {
    private let viewModelFactory: ItemsViewModelFactory
    private let coordinator: ItemsCoordinator

    public init(viewModelFactory: ItemsViewModelFactory, coordinator: ItemsCoordinator) {
        self.viewModelFactory = viewModelFactory
        self.coordinator = coordinator
    }

    public func create(for list: List) -> UIViewController {
        ItemsNavigationController(
            rootViewController: ItemsViewController(
                viewModel: viewModelFactory.create(for: list),
                coordinator: coordinator
            )
        )
    }
}
