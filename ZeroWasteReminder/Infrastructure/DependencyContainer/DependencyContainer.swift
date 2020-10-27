import UIKit
import Swinject

internal final class DependencyContainer {
    private let container: Container
    private var recorder: DependenciesRecorder!
    private var listeners: [Any]

    internal var rootViewController: UIViewController {
        container.resolve(ListsViewControllerFactory.self)!.create()
//        container.resolve(SearchViewControllerFactory.self)!.create()
    }

    internal var remoteNotificationHandler: RemoteNotificationHandler {
        container.resolve(RemoteNotificationHandler.self)!
    }

    internal var userNotificationCenter: UNUserNotificationCenter {
        container.resolve(UNUserNotificationCenter.self)!
    }

    internal init(configuration: DependencyContainerConfiguration) {
        container = Container()
        listeners = []

        recorder = dependenciesRecorder(from: container, and: configuration)
        recorder.register()

        attachListeners()
    }

    internal func startBackgroundServices() {
        container.resolve(AccountService.self)!.refreshUserEligibility()
        container.resolve(SubscriptionService.self)!.registerSubscriptionsIfNeeded()
        container.resolve(ItemNotificationsRescheduler.self)!.reschedule()
    }

    private func dependenciesRecorder(
        from container: Container,
        and configuration: DependencyContainerConfiguration
    ) -> DependenciesRecorder {
        let localStorageRecorder = localStorageDependenciesRecorder(from: configuration)
        let remoteStorageRecorder = remoteStorageDependenciesRecorder(from: container, and: configuration)

        return DependenciesRecorderComposite([
            GeneralDependenciesRecorder(container),
            localStorageRecorder,
            remoteStorageRecorder,
            storageDependencyRecorder(
                container,
                localStorageRecorder.container,
                remoteStorageRecorder.container
            )
        ])
    }

    private func storageDependencyRecorder(
        _ container: Container,
        _ localStorageContainer: Container,
        _ remoteStorageContainer: Container
    ) -> StorageDependencyRecorder {
        .init(container, localStorageContainer, remoteStorageContainer)
    }

    private func localStorageDependenciesRecorder(
        from configuration: DependencyContainerConfiguration
    ) -> LocalStorageDependenciesRecorder {
        switch configuration.localStorage {
        case .coreData:
            return CoreDataLocalStorageDependenciesRecorder()
        case .inMemory:
            return InMemoryLocalStorageDependenciesRecorder()
        }
    }

    private func remoteStorageDependenciesRecorder(
        from container: Container,
        and configuration: DependencyContainerConfiguration
    ) -> RemoteStorageDependenciesRecorder {
        switch configuration.remoteStorage {
        case .cloudKit(let containerIdentifier):
            return CloudKitRemoteStorageDependenciesRecorder(container, containerIdentifier)
        case .inMemory:
            return InMemoryRemoteStorageDependenciesRecorder(container)
        }
    }

    private func attachListeners() {
//        listeners.append(container.resolve(EventDispatcherInterceptor.self)!)
        listeners.append(container.resolve(ScheduleItemNotification.self)!)
        listeners.append(container.resolve(UpdateListsDate.self)!)
    }
}
