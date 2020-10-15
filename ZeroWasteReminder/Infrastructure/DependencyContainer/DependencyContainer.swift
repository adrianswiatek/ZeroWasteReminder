import UIKit
import Swinject

internal final class DependencyContainer {
    private let container: Container
    private var resolver: DependencyResolver!
    private var listeners: [Any]

    internal init(configuration: Configuration) {
        container = Container()
        listeners = []

        resolver = DependencyResolverComposite([
            GeneralDependencyResolver(container),
            infrastructureDependencyResolver(from: configuration)
        ])

        resolver.registerCoordinators()
        resolver.registerEventListeners()
        resolver.registerOtherObjects()
        resolver.registerRepositories()
        resolver.registerServices()
        resolver.registerViewControllerFactories()
        resolver.registerViewModelFactories()

        attachListeners()
    }

    internal var rootViewController: UIViewController {
        container.resolve(ListsViewControllerFactory.self)!.create()
    }

    internal var remoteNotificationHandler: RemoteNotificationHandler {
        container.resolve(RemoteNotificationHandler.self)!
    }

    internal var userNotificationCenter: UNUserNotificationCenter {
        container.resolve(UNUserNotificationCenter.self)!
    }

    internal func startBackgroundServices() {
        container.resolve(AccountService.self)!.refreshUserEligibility()
        container.resolve(SubscriptionService.self)!.registerSubscriptionsIfNeeded()
    }

    private func infrastructureDependencyResolver(
        from configuration: Configuration
    ) -> DependencyResolver {
        switch configuration {
        case .cloudKit(let containerIdentifier):
            return CloudKitDependencyResolver(container, containerIdentifier)
        case .inMemory:
            return InMemoryDependencyResolver(container)
        }
    }

    private func attachListeners() {
        listeners.append(container.resolve(EventDispatcherInterceptor.self)!)
        listeners.append(container.resolve(ScheduleItemNotification.self)!)
        listeners.append(container.resolve(UpdateListsDate.self)!)
        listeners.append(container.resolve(UpdatePersistedItemNotification.self)!)
    }
}

internal extension DependencyContainer {
    enum Configuration {
        case inMemory
        case cloudKit(containerIdentifier: String)
    }
}
