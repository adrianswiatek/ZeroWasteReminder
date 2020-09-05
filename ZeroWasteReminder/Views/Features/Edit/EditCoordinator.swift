import UIKit

public final class EditCoordinator {
    private let imagePickerFactory: ImagePickerControllerFactory
    private let moveItemViewModelFactory: MoveItemViewModelFactory

    public init(
        imagePickerFactory: ImagePickerControllerFactory,
        moveItemViewModelFactory: MoveItemViewModelFactory
    ) {
        self.imagePickerFactory = imagePickerFactory
        self.moveItemViewModelFactory = moveItemViewModelFactory
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

    public func navigateToMoveItem(with item: Item, in viewController: UIViewController) {
        viewController.present(createMoveItemController(for: item), animated: true)
    }

    private func createMoveItemController(for item: Item) -> UIViewController {
        let viewController = MoveItemViewController(viewModel: moveItemViewModelFactory.create(for: item))
        return MoveItemNavigationController(rootViewController: viewController)
    }
}
