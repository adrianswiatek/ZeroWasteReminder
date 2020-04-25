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

        actionsSheet.addAction(.filterItems(handler: {
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
        in viewController: UIViewController
    ) -> AnyPublisher<UIAlertAction, Never> {
        let actionsSubject = PassthroughSubject<UIAlertAction, Never>()

        let actionsSheet: UIAlertController =
            .init(title: "This operation cannot be undone", message: "Are you sure?", preferredStyle: .actionSheet)

        actionsSheet.addAction(.yes(withStyle: .destructive, handler: {
            actionsSubject.send($0)
            actionsSubject.send(completion: .finished)
        }))

        actionsSheet.addAction(.cancel(handler: { _ in
            actionsSubject.send(completion: .finished)
        }))

        viewController.present(actionsSheet, animated: true)
        return actionsSubject.eraseToAnyPublisher()
    }
}
