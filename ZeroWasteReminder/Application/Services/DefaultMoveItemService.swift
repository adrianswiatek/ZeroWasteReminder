import Combine

public final class DefaultMoveItemService: MoveItemService {
    private var fetchListsSubscription: AnyCancellable?
    private var moveItemSubscription: AnyCancellable?

    private let listsRepository: ListsRepository
    private let itemsWriteRepository: ItemsWriteRepository
    private let eventDispatcher: EventDispatcher

    public init(
        listsRepository: ListsRepository,
        itemsWriteRepository: ItemsWriteRepository,
        eventDispatcher: EventDispatcher
    ) {
        self.listsRepository = listsRepository
        self.itemsWriteRepository = itemsWriteRepository
        self.eventDispatcher = eventDispatcher
    }

    deinit {
        print("Deinit")
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
        itemsWriteRepository.move(item, to: list)
    }
}
