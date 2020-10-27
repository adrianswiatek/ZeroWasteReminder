import UIKit

public final class AddItemNavigationController: UINavigationController {
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    public override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)

        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.backgroundColor = .accent
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]

        navigationBar.standardAppearance = navigationBarAppearance

        modalPresentationStyle = .fullScreen
    }

    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("Not supported.")
    }
}
