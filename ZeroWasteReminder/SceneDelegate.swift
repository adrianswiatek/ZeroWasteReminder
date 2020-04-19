import UIKit

internal class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    internal var window: UIWindow?
    private var viewControllerFactory: ViewControllerFactory?

    internal func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let scene = scene as? UIWindowScene else { return }

        viewControllerFactory = ViewControllerFactory()

        window = UIWindow(windowScene: scene)
        window?.rootViewController = viewControllerFactory?.listViewController
        window?.makeKeyAndVisible()
    }
}
