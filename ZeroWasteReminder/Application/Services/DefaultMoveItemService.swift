import Combine

public final class DefaultMoveItemService: MoveItemService {
    private var fetchListsSubscription: AnyCancellable?
    private var moveItemSubscription: AnyCancellable?

    private let listsRepository: ListsRepository
    private let itemsRepository: ItemsRepository
    private let eventDispatcher: EventDispatcher

    public init(listsRepository: ListsRepository, itemsRepository: ItemsRepository, eventDispatcher: EventDispatcher) {
        self.listsRepository = listsRepository
        self.itemsRepository = itemsRepository
        self.eventDispatcher = eventDispatcher
    }

    public func fetchLists(for item: Item) {
        fetchListsSubscription = eventDispatcher.events
            .compactMap { $0 as? ListsFetched }
            .sink { [weak self] in
                let filteredLists = $0.lists.filter { $0.id != item.listId }
                self?.eventDispatcher.dispatch(ListsFetchedForItemToMove(filteredLists, item))
                self?.fetchListsSubscription = nil
            }

        listsRepository.fetchAll()
    }

    public func moveItem(_ item: Item, to list: List) {
        itemsRepository.move(item, to: list)
    }
}
