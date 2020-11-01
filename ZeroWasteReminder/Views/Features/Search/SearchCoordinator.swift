import UIKit

public final class SearchCoordinator {
    private let editItemViewControllerFactory: EditItemViewControllerFactory

    public init(editItemViewControllerFactory: EditItemViewControllerFactory) {
        self.editItemViewControllerFactory = editItemViewControllerFactory
    }

    public func navigateToEdit(for item: Item, in viewController: UIViewController) {
        guard let navigationController = viewController.navigationController else {
            preconditionFailure("Missing navigation controller.")
        }
        navigationController.pushViewController(editItemViewControllerFactory.create(for: item), animated: true)
    }
}
