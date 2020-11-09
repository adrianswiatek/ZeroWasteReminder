public final class SearchViewModelFactory {
    private let listsRepository: ListsRepository
    private let itemsReadRepository: ItemsReadRepository
    private let updateListsDate: UpdateListsDate
    private let eventDispatcher: EventDispatcher

    public init(
        listsRepository: ListsRepository,
        itemsReadRepository: ItemsReadRepository,
        updateListsDate: UpdateListsDate,
        eventDispatcher: EventDispatcher
    ) {
        self.listsRepository = listsRepository
        self.itemsReadRepository = itemsReadRepository
        self.updateListsDate = updateListsDate
        self.eventDispatcher = eventDispatcher
    }

    public func create() -> SearchViewModel {
        SearchViewModel(
            listsRepository: listsRepository,
            itemsRepository: itemsReadRepository,
            updateListsDate: updateListsDate,
            eventDispatcher: eventDispatcher
        )
    }
}
