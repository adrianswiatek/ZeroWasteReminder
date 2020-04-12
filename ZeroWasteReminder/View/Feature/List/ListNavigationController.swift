import UIKit

public final class ListNavigationController: UINavigationController {
    override public var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    public override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)

        navigationBar.barTintColor = .accentColor
        navigationBar.isTranslucent = false

    }

    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("Not supported.")
    }
}
