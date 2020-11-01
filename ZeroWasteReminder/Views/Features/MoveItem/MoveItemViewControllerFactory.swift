import UIKit

public final class MoveItemViewControllerFactory {
    private let viewModelFactory: MoveItemViewModelFactory

    public init(viewModelFactory: MoveItemViewModelFactory) {
        self.viewModelFactory = viewModelFactory
    }

    public func create(for item: Item) -> UIViewController {
        MoveItemNavigationController(
            rootViewController: MoveItemViewController(
                viewModel: viewModelFactory.create(for: item)
            )
        )
    }
}
