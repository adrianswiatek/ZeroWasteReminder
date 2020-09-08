public final class ListsViewModelFactory {
    private let listsRepository: ListsRepository
    private let listUpdater: AutomaticListUpdater
    private let statusNotifier: StatusNotifier
    private let eventBus: EventBus

    public init(
        listsRepository: ListsRepository,
        listUpdater: AutomaticListUpdater,
        statusNotifier: StatusNotifier,
        eventBus: EventBus
    ) {
        self.listsRepository = listsRepository
        self.listUpdater = listUpdater
        self.statusNotifier = statusNotifier
        self.eventBus = eventBus
    }

    public func create() -> ListsViewModel {
        .init(
            listsRepository: listsRepository,
            listUpdater: listUpdater,
            statusNotifier: statusNotifier,
            eventBus: eventBus
        )
    }
}
