import UIKit

public final class AddNavigationController: UINavigationController {
    public override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        self.setupUserInterface()
    }

    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("Not supported.")
    }

    private func setupUserInterface() {
        view.backgroundColor = .accentColor
        navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navigationBar.isTranslucent = false
        navigationBar.prefersLargeTitles = true
    }
}
