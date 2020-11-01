import CloudKit
import UIKit
import UserNotifications

@UIApplicationMain
internal class AppDelegate: UIResponder, UIApplicationDelegate {
    internal let dependencyContainer: DependencyContainer

    private let remoteNotificationHandler: RemoteNotificationHandler
    private let userNotificationCenter: UNUserNotificationCenter

    internal override init() {
        let dependencyContainerConfiguration = DependencyContainerConfiguration(
            localStorage: .coreData,
            remoteStorage: .cloudKit(containerIdentifier: "iCloud.pl.aswiatek.PushNotifications")
        )
//        let dependencyContainerConfiguration = DependencyContainerConfiguration(
//            localStorage: .inMemory,
//            remoteStorage: .inMemory
//        )
        dependencyContainer = .init(configuration: dependencyContainerConfiguration)
        remoteNotificationHandler = dependencyContainer.remoteNotificationHandler
        userNotificationCenter = dependencyContainer.userNotificationCenter

        super.init()
    }

    internal func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        dependencyContainer.startBackgroundServices()
        userNotificationCenter.requestAuthorization(options: [.alert]) { _, _ in }
        application.registerForRemoteNotifications()
        return true
    }

    internal func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    internal func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        remoteNotificationHandler.received(with: userInfo)
        completionHandler(.noData)
    }

    func application(
        _ application: UIApplication,
        userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata
    ) {
        print(cloudKitShareMetadata)
    }
}
