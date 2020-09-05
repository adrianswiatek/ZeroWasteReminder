import UIKit

public final class EmptySharingControllerFactory: SharingControllerFactory {
    public func build() -> UIViewController {
        UIViewController()
    }
}
