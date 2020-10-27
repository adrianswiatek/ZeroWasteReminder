import UIKit

public final class ItemsCoordinator {
    private let sharingControllerFactory: SharingControllerFactory
    private let addItemViewControllerFactory: AddItemViewControllerFactory
    private let editItemViewControllerFactory: EditItemViewControllerFactory
    private let moveItemViewControllerFactory: MoveItemViewControllerFactory
    private let addCoordinator: AddItemCoordinator
    private let editCoordinator: EditItemCoordinator

    public init(
        sharingControllerFactory: SharingControllerFactory,
        addItemViewControllerFactory: AddItemViewControllerFactory,
        editItemViewControllerFactory: EditItemViewControllerFactory,
        moveItemViewControllerFactory: MoveItemViewControllerFactory,
        addCoordinator: AddItemCoordinator,
        editCoordinator: EditItemCoordinator
    ) {
        self.sharingControllerFactory = sharingControllerFactory
        self.addItemViewControllerFactory = addItemViewControllerFactory
        self.editItemViewControllerFactory = editItemViewControllerFactory
        self.moveItemViewControllerFactory = moveItemViewControllerFactory
        self.addCoordinator = addCoordinator
        self.editCoordinator = editCoordinator
    }

    public func navigateToAdd(for list: List, in viewController: UIViewController) {
        let addItemViewController = addItemViewControllerFactory.create(for: list)
        addItemViewController.modalPresentationStyle = .fullScreen
        viewController.present(addItemViewController, animated: true)
    }

    public func navigateToEdit(for item: Item, in viewController: UIViewController) {
        guard let navigationController = viewController.navigationController else {
            preconditionFailure("Missing navigation controller.")
        }
        navigationController.pushViewController(editItemViewControllerFactory.create(for: item), animated: true)
    }

    public func navigateToMoveItem(with item: Item, in viewController: UIViewController) {
        let moveItemViewController = moveItemViewControllerFactory.create(for: item)
        moveItemViewController.modalPresentationStyle = .fullScreen
        viewController.present(moveItemViewController, animated: true)
    }

    public func navigateToSharing(in viewController: UIViewController) {
        viewController.present(sharingControllerFactory.create(), animated: true)
    }
}
