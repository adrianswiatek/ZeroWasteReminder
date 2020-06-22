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
        let itemsRepository = InMemoryItemsRepository()
        let remotePersistenceFactory = buildRemotePersistenceFactory(itemsRepository, fileService)

        let accountService = remotePersistenceFactory.accountService()
        accountService.refreshUserEligibility()

        let remoteStatusNotifier = RemoteStatusNotifier(accountService: accountService)

        subscriptionService = remotePersistenceFactory.subscriptionService(remoteStatusNotifier: remoteStatusNotifier)
        subscriptionService?.registerItemsSubscriptionIfNeeded()

        viewControllerFactory = ViewControllerFactory(
            itemsService: remotePersistenceFactory.itemsService(),
            photosService: remotePersistenceFactory.photosService(),
            fileService: fileService,
            itemsRepository: itemsRepository,
            remoteStatusNotifier: remoteStatusNotifier,
            sharingControllerFactory: remotePersistenceFactory.sharingControllerFactory()
        )

        window = UIWindow(windowScene: scene)
        window?.rootViewController = viewControllerFactory?.listViewController
        window?.makeKeyAndVisible()
    }

    private func buildRemotePersistenceFactory(
        _ itemsRepository: ItemsRepository,
        _ fileService: FileService
    ) -> RemotePersistenceFactory {
        CloudKitPersistenceFactory(
            containerIdentifier: "iCloud.pl.aswiatek.PushNotifications",
            itemsRepository: itemsRepository,
            fileService: fileService,
            notificationCenter: .default
        )
    }
}
