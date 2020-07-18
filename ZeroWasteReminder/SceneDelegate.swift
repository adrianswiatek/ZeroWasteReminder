import CloudKit
import UIKit

internal class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    internal var window: UIWindow?

    private var dependencyContainer: DependencyContainer?

    internal func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let scene = scene as? UIWindowScene else { return }

        dependencyContainer = DependencyContainer(configuration: .inMemory)

        window = UIWindow(windowScene: scene)
        window?.rootViewController = dependencyContainer?.rootViewController
        window?.makeKeyAndVisible()
    }
}
