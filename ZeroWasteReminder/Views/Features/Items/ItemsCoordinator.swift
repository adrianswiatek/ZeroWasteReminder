import UIKit

public final class ItemsCoordinator {
    private let sharingControllerFactory: SharingControllerFactory
    private let addViewModelFactory: AddItemViewModelFactory
    private let editViewModelFactory: EditItemViewModelFactory
    private let moveItemViewModelFactory: MoveItemViewModelFactory
    private let addCoordinator: AddCoordinator
    private let editCoordinator: EditCoordinator

    public init(
        sharingControllerFactory: SharingControllerFactory,
        addViewModelFactory: AddItemViewModelFactory,
        editViewModelFactory: EditItemViewModelFactory,
        moveItemViewModelFactory: MoveItemViewModelFactory,
        addCoordinator: AddCoordinator,
        editCoordinator: EditCoordinator
    ) {
        self.sharingControllerFactory = sharingControllerFactory
        self.addViewModelFactory = addViewModelFactory
        self.editViewModelFactory = editViewModelFactory
        self.moveItemViewModelFactory = moveItemViewModelFactory
        self.addCoordinator = addCoordinator
        self.editCoordinator = editCoordinator
    }

    public func navigateToAdd(for list: List, in viewController: UIViewController) {
        viewController.present(createAddViewController(for: list), animated: true)
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

    private func createAddViewController(for list: List) -> UIViewController {
        let viewModel = addViewModelFactory.create(for: list)
        let viewController = AddViewController(viewModel: viewModel, coordinator: addCoordinator)
        return AddNavigationController(rootViewController: viewController)
    }

    private func createEditViewController(for item: Item) -> UIViewController {
        let viewModel = editViewModelFactory.create(for: item)
        return EditViewController(viewModel: viewModel, coordinator: editCoordinator)
    }

    private func createMoveItemController(for item: Item) -> UIViewController {
        let viewModel = moveItemViewModelFactory.create(for: item)
        let viewController = MoveItemViewController(viewModel: viewModel)
        return MoveItemNavigationController(rootViewController: viewController)
    }
}
