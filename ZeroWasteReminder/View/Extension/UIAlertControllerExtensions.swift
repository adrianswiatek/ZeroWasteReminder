import Combine
import UIKit

public extension UIAlertController {
        static func presentActionsSheet(
        in viewController: UIViewController
    ) -> AnyPublisher<UIAlertAction, Never> {
        let actionsSubject = PassthroughSubject<UIAlertAction, Never>()

        let actionsSheet: UIAlertController =
            .init(title: "Actions", message: nil, preferredStyle: .actionSheet)

        actionsSheet.addAction(.selectItems(handler: {
            actionsSubject.send($0)
            actionsSubject.send(completion: .finished)
        }))

        actionsSheet.addAction(.shareList(handler: {
            actionsSubject.send($0)
            actionsSubject.send(completion: .finished)
        }))

        actionsSheet.addAction(.deleteAll(handler: {
            actionsSubject.send($0)
            actionsSubject.send(completion: .finished)
        }))

        actionsSheet.addAction(.cancel(handler: { _ in
            actionsSubject.send(completion: .finished)
        }))

        viewController.present(actionsSheet, animated: true)
        return actionsSubject.eraseToAnyPublisher()
    }

    static func presentConfirmationSheet(
        in viewController: UIViewController,
        withConfirmationStyle confirmationButtonStyle: UIAlertAction.Style = .default
    ) -> AnyPublisher<UIAlertAction, Never> {
        let actionsSubject = PassthroughSubject<UIAlertAction, Never>()

        let actionsSheet: UIAlertController =
            .init(title: "This operation cannot be undone", message: "Are you sure?", preferredStyle: .actionSheet)

        actionsSheet.addAction(.yes(withStyle: confirmationButtonStyle, handler: {
            actionsSubject.send($0)
            actionsSubject.send(completion: .finished)
        }))

        actionsSheet.addAction(.cancel(handler: { _ in
            actionsSubject.send(completion: .finished)
        }))

        viewController.present(actionsSheet, animated: true)
        return actionsSubject.eraseToAnyPublisher()
    }

    static func presentError(in viewController: UIViewController, withMessage message: String) {
        let alertController = UIAlertController(title: "Oups", message: message, preferredStyle: .alert)
        alertController.addAction(.ok)
        viewController.present(alertController, animated: true)
    }
}
