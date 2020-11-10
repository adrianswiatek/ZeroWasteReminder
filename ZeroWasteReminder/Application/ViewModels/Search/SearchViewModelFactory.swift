public final class SearchViewModelFactory {
    private let listsRepository: ListsRepository
    private let itemsReadRepository: ItemsReadRepository
    private let statusNotifier: StatusNotifier
    private let updateListsDate: UpdateListsDate
    private let eventDispatcher: EventDispatcher

    public init(
        listsRepository: ListsRepository,
        itemsReadRepository: ItemsReadRepository,
        statusNotifier: StatusNotifier,
        updateListsDate: UpdateListsDate,
        eventDispatcher: EventDispatcher
    ) {
        self.listsRepository = listsRepository
        self.itemsReadRepository = itemsReadRepository
        self.statusNotifier = statusNotifier
        self.updateListsDate = updateListsDate
        self.eventDispatcher = eventDispatcher
    }

    public func create() -> SearchViewModel {
        SearchViewModel(
            listsRepository: listsRepository,
            itemsRepository: itemsReadRepository,
            statusNotifier: statusNotifier,
            updateListsDate: updateListsDate,
            eventDispatcher: eventDispatcher
        )
    }
}
