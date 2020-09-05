import Combine
import UIKit

public final class RemoteErrorNotifier {
    private let window: UIWindow?

    public init(window: UIWindow?) {
        self.window = window
    }

    public func notify(about error: ServiceError) {
        guard let viewController = window?.rootViewController, case error else { return }
        UIAlertController.presentError(in: viewController, withMessage: <#T##String#>)
    }
}
