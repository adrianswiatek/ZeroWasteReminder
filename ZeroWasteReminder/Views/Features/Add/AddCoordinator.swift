import UIKit

public final class AddCoordinator {
    private let imagePickerFactory: ImagePickerControllerFactory

    public init(imagePickerFactory: ImagePickerControllerFactory) {
        self.imagePickerFactory = imagePickerFactory
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
}
