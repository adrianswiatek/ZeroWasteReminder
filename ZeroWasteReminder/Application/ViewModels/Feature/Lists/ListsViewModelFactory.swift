public final class ListsViewModelFactory {
    private let listsRepository: ListsRepository
    private let statusNotifier: StatusNotifier
    private let eventBus: EventBus

    public init(
        listsRepository: ListsRepository,
        statusNotifier: StatusNotifier,
        eventBus: EventBus
    ) {
        self.listsRepository = listsRepository
        self.statusNotifier = statusNotifier
        self.eventBus = eventBus
    }

    public func create() -> ListsViewModel {
        .init(
            listsRepository: listsRepository,
            statusNotifier: statusNotifier,
            eventBus: eventBus
        )
    }
}
