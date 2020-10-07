import UIKit

public final class EditCoordinator {
    private let imagePickerFactory: ImagePickerControllerFactory
    private let moveItemViewModelFactory: MoveItemViewModelFactory
    private let eventDispatcher: EventDispatcher

    public init(
        imagePickerFactory: ImagePickerControllerFactory,
        moveItemViewModelFactory: MoveItemViewModelFactory,
        eventDispatcher: EventDispatcher
    ) {
        self.imagePickerFactory = imagePickerFactory
        self.moveItemViewModelFactory = moveItemViewModelFactory
        self.eventDispatcher = eventDispatcher
    }

    public func navigateToImagePicker(
        for target: PhotoCaptureTarget,
        with delegate: UIImagePickerControllerDelegate & UINavigationControllerDelegate,
        in viewController: UIViewController
    ) {
        imagePickerFactory.create(for: target, with: delegate).map {
            viewController.present($0, animated: true)
        }
    }

    public func navigateToAlert(withOption option: AlertOption, in viewController: UIViewController) {
        guard let navigationController = viewController.navigationController else {
            preconditionFailure("Missing navigation controller.")
        }

        let viewModel = AlertViewModel(selectedOption: option, eventDispatcher: eventDispatcher)
        let viewController = AlertViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }

    public func navigateToMoveItem(with item: Item, in viewController: UIViewController) {
        viewController.present(createMoveItemController(for: item), animated: true)
    }

    private func createMoveItemController(for item: Item) -> UIViewController {
        let viewController = MoveItemViewController(viewModel: moveItemViewModelFactory.create(for: item))
        return MoveItemNavigationController(rootViewController: viewController)
    }
}
