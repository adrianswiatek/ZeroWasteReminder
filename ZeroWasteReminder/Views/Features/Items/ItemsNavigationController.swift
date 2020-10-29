import UIKit

public final class ItemsNavigationController: UINavigationController {
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    public override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)

        navigationBar.isTranslucent = false
        navigationBar.tintColor = .white
        navigationBar.standardAppearance = configure(UINavigationBarAppearance()) {
            $0.backgroundColor = .accent
            $0.shadowColor = .clear
            $0.titleTextAttributes = [.foregroundColor: UIColor.white]
        }
    }

    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("Not supported.")
    }
}
