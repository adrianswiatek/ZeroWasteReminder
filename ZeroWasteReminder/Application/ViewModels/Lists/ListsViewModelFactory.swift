public final class ListsViewModelFactory {
    private let listsRepository: ListsRepository
    private let statusNotifier: StatusNotifier
    private let eventDispatcher: EventDispatcher

    public init(
        listsRepository: ListsRepository,
        statusNotifier: StatusNotifier,
        eventDispatcher: EventDispatcher
    ) {
        self.listsRepository = listsRepository
        self.statusNotifier = statusNotifier
        self.eventDispatcher = eventDispatcher
    }

    public func create() -> ListsViewModel {
        ListsViewModel(
            listsRepository: listsRepository,
            statusNotifier: statusNotifier,
            eventDispatcher: eventDispatcher
        )
    }
}
