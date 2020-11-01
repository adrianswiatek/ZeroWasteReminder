public final class SearchViewModelFactory {
    private let listsRepository: ListsRepository
    private let itemsReadRepository: ItemsReadRepository
    private let eventDispatcher: EventDispatcher

    public init(
        listsRepository: ListsRepository,
        itemsReadRepository: ItemsReadRepository,
        eventDispatcher: EventDispatcher
    ) {
        self.listsRepository = listsRepository
        self.itemsReadRepository = itemsReadRepository
        self.eventDispatcher = eventDispatcher
    }

    public func create() -> SearchViewModel {
        SearchViewModel(
            listsRepository: listsRepository,
            itemsRepository: itemsReadRepository,
            eventDispatcher: eventDispatcher
        )
    }
}
