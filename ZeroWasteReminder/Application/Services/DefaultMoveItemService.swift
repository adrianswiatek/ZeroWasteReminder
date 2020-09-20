import Combine

public final class DefaultMoveItemService: MoveItemService {
    private var fetchListsSubscription: AnyCancellable?
    private var moveItemSubscription: AnyCancellable?

    private let listsRepository: ListsRepository
    private let itemsRepository: ItemsRepository
    private let eventDispatcher: EventDispatcher

    public init(
        listsRepository: ListsRepository,
        itemsRepository: ItemsRepository,
        eventDispatcher: EventDispatcher
    ) {
        self.listsRepository = listsRepository
        self.itemsRepository = itemsRepository
        self.eventDispatcher = eventDispatcher
    }

    public func fetchLists(for item: Item) -> AnyPublisher<[List], Never> {
        listsRepository.fetchAll()
            .flatMap { lists -> AnyPublisher<[List], Never> in
                let filteredLists = lists.filter { $0.id != item.listId }
                return Just(filteredLists).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    public func moveItem(_ item: Item, to list: List) {
        itemsRepository.move(item, to: list)
    }
}
