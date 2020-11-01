import UIKit

public final class AddItemViewControllerFactory {
    private let viewModelFactory: AddItemViewModelFactory
    private let coordinator: AddItemCoordinator

    public init(viewModelFactory: AddItemViewModelFactory, coordinator: AddItemCoordinator) {
        self.viewModelFactory = viewModelFactory
        self.coordinator = coordinator
    }

    public func create(for list: List) -> UIViewController {
        AddItemNavigationController(
            rootViewController: AddItemViewController(
                viewModel: viewModelFactory.create(for: list),
                coordinator: coordinator
            )
        )
    }
}
