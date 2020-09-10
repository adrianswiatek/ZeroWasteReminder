public final class ListsViewModelFactory {
    private let listsRepository: ListsRepository
    private let eventDispatcher: EventDispatcher
    private let statusNotifier: StatusNotifier

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
        .init(
            listsRepository: listsRepository,
            statusNotifier: statusNotifier,
            eventDispatcher: eventDispatcher
        )
    }
}
