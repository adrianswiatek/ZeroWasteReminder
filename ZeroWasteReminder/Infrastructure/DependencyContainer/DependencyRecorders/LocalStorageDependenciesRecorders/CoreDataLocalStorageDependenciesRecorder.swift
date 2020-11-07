import Swinject

internal struct CoreDataLocalStorageDependenciesRecorder: LocalStorageDependenciesRecorder {
    internal let container = Container()

    internal func register() {
        registerOtherObjects()
        registerRepositories()
    }

    private func registerOtherObjects() {
        container.register(CoreDataStack.self) { _ in
            CoreDataStack()
        }.inObjectScope(.container)

        container.register(CoreDataMapper.self) { _ in
            CoreDataMapper()
        }
    }

    private func registerRepositories() {
        container.register(ItemNotificationsRepository.self) { resolver in
            CoreDataItemNotificationsRepository(
                coreDataStack: resolver.resolve(CoreDataStack.self)!,
                mapper: resolver.resolve(CoreDataMapper.self)!
            )
        }
    }
}
