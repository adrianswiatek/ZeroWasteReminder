public final class DependencyResolverComposite: DependencyResolver {
    private var resolvers: [DependencyResolver]

    public init(_ resolvers: [DependencyResolver]) {
        self.resolvers = resolvers
    }

    public func registerCoordinators() {
        resolvers.forEach { $0.registerCoordinators() }
    }

    public func registerEventListeners() {
        resolvers.forEach { $0.registerEventListeners() }
    }

    public func registerOtherObjects() {
        resolvers.forEach { $0.registerOtherObjects() }
    }

    public func registerRepositories() {
        resolvers.forEach { $0.registerRepositories() }
    }

    public func registerServices() {
        resolvers.forEach { $0.registerServices() }
    }

    public func registerViewControllerFactories() {
        resolvers.forEach { $0.registerViewControllerFactories() }
    }

    public func registerViewModelFactories() {
        resolvers.forEach { $0.registerViewModelFactories() }
    }
}
