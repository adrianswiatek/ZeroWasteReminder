import UIKit
import Swinject

internal final class DependencyContainer {
    private let container: Container
    private var resolver: DependencyResolver!

    internal init(configuration: Configuration) {
        container = Container()

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
    }

    internal var rootViewController: UIViewController {
        container.resolve(ListsViewControllerFactory.self)!.create()
    }

    internal var remoteNotificationHandler: RemoteNotificationHandler {
        container.resolve(RemoteNotificationHandler.self)!
    }

    internal func startBackgroundServices() {
        container.resolve(AccountService.self)!.refreshUserEligibility()
        container.resolve(SubscriptionService.self)!.registerSubscriptionsIfNeeded()
        container.resolve(EventDispatcherInterceptor.self)!.startIntercept()
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
}

internal extension DependencyContainer {
    enum Configuration {
        case inMemory
        case cloudKit(containerIdentifier: String)
    }
}
