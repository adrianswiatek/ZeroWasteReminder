import UIKit

public final class EditItemCoordinator {
    private let imagePickerFactory: ImagePickerControllerFactory
    private let moveItemViewControllerFactory: MoveItemViewControllerFactory
    private let eventDispatcher: EventDispatcher

    public init(
        imagePickerFactory: ImagePickerControllerFactory,
        moveItemViewControllerFactory: MoveItemViewControllerFactory,
        eventDispatcher: EventDispatcher
    ) {
        self.imagePickerFactory = imagePickerFactory
        self.moveItemViewControllerFactory = moveItemViewControllerFactory
        self.eventDispatcher = eventDispatcher
    }

    public func navigateToImagePicker(
        for target: PhotoCaptureTarget,
        with delegate: UIImagePickerControllerDelegate & UINavigationControllerDelegate,
        in viewController: UIViewController,
        completion: @escaping () -> Void
    ) {
        if let imagePickerController = imagePickerFactory.create(for: target, with: delegate) {
            imagePickerController.modalPresentationStyle = .fullScreen
            viewController.present(imagePickerController, animated: true, completion: completion)
        } else {
            completion()
        }
    }

    public func navigateToFullScreenPhoto(with photo: Photo, in viewController: UIViewController) {
        let fullScreenPhotoViewController = FullScreenPhotoViewController(image: photo.asImage)
        fullScreenPhotoViewController.modalPresentationStyle = .fullScreen
        viewController.present(fullScreenPhotoViewController, animated: true)
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
        let moveItemViewController = moveItemViewControllerFactory.create(for: item)
        moveItemViewController.modalPresentationStyle = .fullScreen
        viewController.present(moveItemViewController, animated: true)
    }
}
