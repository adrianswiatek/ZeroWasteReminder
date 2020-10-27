import UIKit

public final class ItemsNavigationController: UINavigationController {
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    public override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)

        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.backgroundColor = .accent
        navigationBarAppearance.shadowColor = .clear
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]

        navigationBar.standardAppearance = navigationBarAppearance
        navigationBar.isTranslucent = false
        navigationBar.tintColor = .white
    }

    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("Not supported.")
    }
}
