import UIKit

public final class ListsNavigationController: UINavigationController {
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    public override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)

        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.backgroundColor = .accent
        navigationBarAppearance.shadowColor = .clear
        navigationBarAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 18, weight: .bold)
        ]

        navigationBar.standardAppearance = navigationBarAppearance
        navigationBar.isTranslucent = false
    }

    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("Not supported.")
    }
}
