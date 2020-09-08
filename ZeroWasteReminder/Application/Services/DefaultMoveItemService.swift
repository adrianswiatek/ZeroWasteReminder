import Combine

public final class DefaultMoveItemService: MoveItemService {
    private var fetchListsSubscription: AnyCancellable?
    private var moveItemSubscription: AnyCancellable?

    private let listsRepository: ListsRepository
    private let itemsRepository: ItemsRepository
    private let eventBus: EventBus

    public init(listsRepository: ListsRepository, itemsRepository: ItemsRepository, eventBus: EventBus) {
        self.listsRepository = listsRepository
        self.itemsRepository = itemsRepository
        self.eventBus = eventBus
    }

    public func fetchLists(for item: Item) {
        fetchListsSubscription = eventBus.events
            .compactMap { $0 as? ListsFetchedEvent }
            .sink { [weak self] in
                let filteredLists = $0.lists.filter { $0.id != item.listId }
                self?.eventBus.send(ListsFetchedForItemToMoveEvent(filteredLists, item))
                self?.fetchListsSubscription = nil
            }

        listsRepository.fetchAll()
    }

    public func moveItem(_ item: Item, to list: List) {
        itemsRepository.move(item, to: list)
    }
}
