import CloudKit
import UIKit

internal class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    internal var window: UIWindow?
    private var viewControllerFactory: ViewControllerFactory?
    private var subscriptionService: SubscriptionService?

    internal func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let scene = scene as? UIWindowScene else { return }

        let fileService = FileService()

        let remotePersistenceFactory: RemotePersistenceFactory = CloudKitPersistenceFactory(
            containerIdentifier: "iCloud.pl.aswiatek.PushNotifications",
            fileService: fileService
        )

        subscriptionService = remotePersistenceFactory.subscriptionService()
        subscriptionService?.registerItemsSubscriptionIfNeeded()

        viewControllerFactory = ViewControllerFactory(
            itemsService: remotePersistenceFactory.itemsService(),
            sharingControllerFactory: remotePersistenceFactory.sharingControllerFactory(),
            fileService: fileService
        )

        window = UIWindow(windowScene: scene)
        window?.rootViewController = viewControllerFactory?.listViewController
        window?.makeKeyAndVisible()
    }
}
