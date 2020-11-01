import UIKit

public final class EditItemViewControllerFactory {
    private let viewModelFactory: EditItemViewModelFactory
    private let coordinator: EditItemCoordinator

    public init(viewModelFactory: EditItemViewModelFactory, coordinator: EditItemCoordinator) {
        self.viewModelFactory = viewModelFactory
        self.coordinator = coordinator
    }

    public func create(for item: Item) -> UIViewController {
        EditItemViewController(
            viewModel: viewModelFactory.create(for: item),
            coordinator: coordinator
        )
    }
}
