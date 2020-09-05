public final class ListsViewModelFactory {
    private let listsRepository: ListsRepository
    private let listsChangeListener: ListsChangeListener
    private let statusNotifier: StatusNotifier

    public init(
        listsRepository: ListsRepository,
        listsChangeListener: ListsChangeListener,
        statusNotifier: StatusNotifier
    ) {
        self.listsRepository = listsRepository
        self.listsChangeListener = listsChangeListener
        self.statusNotifier = statusNotifier
    }

    public func create() -> ListsViewModel {
        .init(
            listsRepository: listsRepository,
            listsChangeListener: listsChangeListener,
            statusNotifier: statusNotifier
        )
    }
}
