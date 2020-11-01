import UIKit

public final class AddItemCoordinator {
    private let imagePickerFactory: ImagePickerControllerFactory
    private let eventDispatcher: EventDispatcher

    public init(imagePickerFactory: ImagePickerControllerFactory, eventDispatcher: EventDispatcher) {
        self.imagePickerFactory = imagePickerFactory
        self.eventDispatcher = eventDispatcher
    }

    public func navigateToImagePicker(
        for target: PhotoCaptureTarget,
        with delegate: UIImagePickerControllerDelegate & UINavigationControllerDelegate,
        in viewController: UIViewController,
        beforePresenting: @escaping () -> Void,
        afterPresenting: @escaping () -> Void
    ) {
        imagePickerFactory.create(for: target, with: delegate).map {
            beforePresenting()
            viewController.present($0, animated: true, completion: afterPresenting)
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

    public func navigateToFullScreenPhoto(for photo: Photo, in viewController: UIViewController) {
        let photoViewController = FullScreenPhotoViewController(image: photo.asImage)
        photoViewController.modalPresentationStyle = .fullScreen
        viewController.present(photoViewController, animated: true)
    }
}
