import UIKit

public final class MoveItemViewControllerFactory {
    private let viewModel: MoveItemViewModel

    public init(viewModel: MoveItemViewModel) {
        self.viewModel = viewModel
    }

    public func create(for item: Item) -> UIViewController {
        viewModel.set(for: item)

        return MoveItemNavigationController(
            rootViewController: MoveItemViewController(viewModel: viewModel)
        )
    }
}
