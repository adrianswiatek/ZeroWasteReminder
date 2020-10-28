import UIKit

public final class EditItemViewControllerFactory {
    private let viewModel: EditItemViewModel
    private let coordinator: EditItemCoordinator

    public init(viewModel: EditItemViewModel, coordinator: EditItemCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator
    }

    public func create(for item: Item) -> UIViewController {
        viewModel.set(for: item)

        return EditItemViewController(
            viewModel: viewModel,
            coordinator: coordinator
        )
    }
}
