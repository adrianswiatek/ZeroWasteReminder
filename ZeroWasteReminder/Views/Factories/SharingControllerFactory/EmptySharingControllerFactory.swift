import UIKit

public final class EmptySharingControllerFactory: SharingControllerFactory {
    public func create() -> UIViewController {
        UIViewController()
    }
}
