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
        let listsRepository = InMemoryListsRepository()
        let notificationCenter = NotificationCenter.default
        let remotePersistenceFactory = buildRemotePersistenceFactory(itemsRepository, fileService, notificationCenter)

        let accountService = remotePersistenceFactory.accountService()
        accountService.refreshUserEligibility()

        let remoteStatusNotifier = RemoteStatusNotifier(accountService: accountService)

        subscriptionService = remotePersistenceFactory.subscriptionService(remoteStatusNotifier: remoteStatusNotifier)
        subscriptionService?.registerItemsSubscriptionIfNeeded()

        viewControllerFactory = ViewControllerFactory(
            itemsService: remotePersistenceFactory.itemsService(),
            photosRepository: remotePersistenceFactory.photosRepository(),
            fileService: fileService,
            itemsRepository: itemsRepository,
            listsRepository: listsRepository,
            remoteStatusNotifier: remoteStatusNotifier,
            sharingControllerFactory: remotePersistenceFactory.sharingControllerFactory(),
            notificationCenter: notificationCenter
        )

        window = UIWindow(windowScene: scene)
        window?.rootViewController = viewControllerFactory?.listsViewController
        window?.makeKeyAndVisible()
    }

    private func buildRemotePersistenceFactory(
        _ itemsRepository: ItemsRepository,
        _ fileService: FileService,
        _ notificationCenter: NotificationCenter
    ) -> RemotePersistenceFactory {
        CloudKitPersistenceFactory(
            containerIdentifier: "iCloud.pl.aswiatek.PushNotifications",
            itemsRepository: itemsRepository,
            fileService: fileService,
            notificationCenter: notificationCenter
        )
    }
}
