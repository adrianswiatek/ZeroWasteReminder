import UIKit

public final class ItemsCoordinator {
    private let sharingControllerFactory: SharingControllerFactory
    private let addItemViewControllerFactory: AddItemViewControllerFactory
    private let editViewModelFactory: EditItemViewModelFactory
    private let moveItemViewModelFactory: MoveItemViewModelFactory
    private let addCoordinator: AddItemCoordinator
    private let editCoordinator: EditItemCoordinator

    public init(
        sharingControllerFactory: SharingControllerFactory,
        addItemViewControllerFactory: AddItemViewControllerFactory,
        editViewModelFactory: EditItemViewModelFactory,
        moveItemViewModelFactory: MoveItemViewModelFactory,
        addCoordinator: AddItemCoordinator,
        editCoordinator: EditItemCoordinator
    ) {
        self.sharingControllerFactory = sharingControllerFactory
        self.addItemViewControllerFactory = addItemViewControllerFactory
        self.editViewModelFactory = editViewModelFactory
        self.moveItemViewModelFactory = moveItemViewModelFactory
        self.addCoordinator = addCoordinator
        self.editCoordinator = editCoordinator
    }

    public func navigateToAdd(for list: List, in viewController: UIViewController) {
        viewController.present(addItemViewControllerFactory.create(for: list), animated: true)
    }

    public func navigateToEdit(for item: Item, in viewController: UIViewController) {
        guard let navigationController = viewController.navigationController else {
            preconditionFailure("Missing navigation controller.")
        }
        navigationController.pushViewController(createEditViewController(for: item), animated: true)
    }

    public func navigateToMoveItem(with item: Item, in viewController: UIViewController) {
        viewController.present(createMoveItemController(for: item), animated: true)
    }

    public func navigateToSharing(in viewController: UIViewController) {
        viewController.present(sharingControllerFactory.build(), animated: true)
    }

    private func createEditViewController(for item: Item) -> UIViewController {
        let viewModel = editViewModelFactory.create(for: item)
        return EditItemViewController(viewModel: viewModel, coordinator: editCoordinator)
    }

    private func createMoveItemController(for item: Item) -> UIViewController {
        let viewModel = moveItemViewModelFactory.create(for: item)
        let viewController = MoveItemViewController(viewModel: viewModel)
        return MoveItemNavigationController(rootViewController: viewController)
    }
}
