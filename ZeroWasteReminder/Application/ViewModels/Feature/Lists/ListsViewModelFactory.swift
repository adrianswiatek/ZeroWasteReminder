public final class ListsViewModelFactory {
    private let listsRepository: ListsRepository
    private let statusNotifier: StatusNotifier

    public init(listsRepository: ListsRepository, statusNotifier: StatusNotifier) {
        self.listsRepository = listsRepository
        self.statusNotifier = statusNotifier
    }

    public func create() -> ListsViewModel {
        .init(listsRepository: listsRepository, statusNotifier: statusNotifier)
    }
}
