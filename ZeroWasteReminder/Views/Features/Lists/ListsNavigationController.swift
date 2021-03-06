import UIKit

public final class ListsNavigationController: UINavigationController {
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    public override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)

        navigationBar.isTranslucent = false
        navigationBar.standardAppearance = configure(UINavigationBarAppearance()) {
            $0.backgroundColor = .accent
            $0.shadowColor = .clear
            $0.titleTextAttributes = [
                .foregroundColor: UIColor.white,
                .font: UIFont.systemFont(ofSize: 18, weight: .bold)
            ]
        }
    }

    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("Not supported.")
    }
}
