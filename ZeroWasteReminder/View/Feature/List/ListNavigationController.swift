import UIKit

public final class ListNavigationController: UINavigationController {
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    public override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)

        navigationBar.barTintColor = .accent
        navigationBar.isTranslucent = false
    }

    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("Not supported.")
    }
}
