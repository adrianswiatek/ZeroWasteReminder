import CloudKit
import UIKit

internal class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    internal var window: UIWindow?

    internal func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let scene = scene as? UIWindowScene else { return }
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }

        window = UIWindow(windowScene: scene)
        window?.rootViewController = appDelegate.dependencyContainer.rootViewController
        window?.makeKeyAndVisible()
    }
}
