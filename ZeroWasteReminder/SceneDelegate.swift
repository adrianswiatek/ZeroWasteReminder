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
        let remotePersistenceFactory = buildRemotePersistenceFactory(fileService: fileService)

        let accountService = remotePersistenceFactory.accountService()
        accountService.refreshUserEligibility()

        let remoteStatusNotifier = RemoteStatusNotifier(accountService: accountService)

        subscriptionService = remotePersistenceFactory.subscriptionService(remoteStatusNotifier: remoteStatusNotifier)
        subscriptionService?.registerItemsSubscriptionIfNeeded()

        viewControllerFactory = ViewControllerFactory(
            itemsService: remotePersistenceFactory.itemsService(),
            remoteStatusNotifier: remoteStatusNotifier,
            sharingControllerFactory: remotePersistenceFactory.sharingControllerFactory(),
            fileService: fileService
        )

        window = UIWindow(windowScene: scene)
        window?.rootViewController = viewControllerFactory?.listViewController
        window?.makeKeyAndVisible()
    }

    private func buildRemotePersistenceFactory(fileService: FileService) -> RemotePersistenceFactory {
        CloudKitPersistenceFactory(
            containerIdentifier: "iCloud.pl.aswiatek.PushNotifications",
            fileService: fileService,
            notificationCenter: .default
        )
    }
}
