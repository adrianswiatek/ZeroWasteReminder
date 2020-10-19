import UIKit

public final class AddCoordinator {
    private let imagePickerFactory: ImagePickerControllerFactory
    private let eventDispatcher: EventDispatcher

    public init(imagePickerFactory: ImagePickerControllerFactory, eventDispatcher: EventDispatcher) {
        self.imagePickerFactory = imagePickerFactory
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
}
