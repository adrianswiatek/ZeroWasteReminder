import Swinject

internal struct InMemoryLocalStorageDependenciesRecorder: LocalStorageDependenciesRecorder {
    internal let container = Container()

    internal func register() {
        registerRepositories()
    }

    private func registerRepositories() {
        container.register(ItemNotificationsRepository.self) { _ in
            InMemoryNotificationsRepository()
        }
    }
}
