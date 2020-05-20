import CloudKit
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

        viewControllerFactory = ViewControllerFactory(itemsService: cloudKitItemsService())

        window = UIWindow(windowScene: scene)
        window?.rootViewController = viewControllerFactory?.listViewController
        window?.makeKeyAndVisible()
    }

    private func cloudKitItemsService() -> ItemsService {
        let container = CKContainer(identifier: "iCloud.pl.aswiatek.PushNotifications")
        return CloudKitItemsService(
            container: container,
            subscriptionService: CloudKitSubscriptionService(container),
            mapper: CloudKitMapper(),
            notificationCenter: .default
        )
    }
}
