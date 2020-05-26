import UIKit

public final class AddNavigationController: UINavigationController {
    public override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)

        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.backgroundColor = .accent
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]

        navigationBar.standardAppearance = navigationBarAppearance
    }

    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("Not supported.")
    }
}
