import UIKit

public final class AddItemViewControllerFactory {
    private let viewModel: AddItemViewModel
    private let coordinator: AddItemCoordinator

    public init(viewModel: AddItemViewModel, coordinator: AddItemCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator
    }

    public func create(for list: List) -> UIViewController {
        viewModel.set(list)

        return AddItemNavigationController(
            rootViewController: AddItemViewController(
                viewModel: viewModel,
                coordinator: coordinator
            )
        )
    }
}
