import Combine

public final class DefaultMoveItemService: MoveItemService {
    public var events: AnyPublisher<MoveItemEvent, Never> {
        eventsSubject.share().eraseToAnyPublisher()
    }

    private let eventsSubject: PassthroughSubject<MoveItemEvent, Never>

    private var fetchListsSubscription: AnyCancellable?
    private var moveItemSubscription: AnyCancellable?

    private let listsRepository: ListsRepository
    private let itemsRepository: ItemsRepository

    public init(listsRepository: ListsRepository, itemsRepository: ItemsRepository) {
        self.listsRepository = listsRepository
        self.itemsRepository = itemsRepository
        self.eventsSubject = .init()
    }

    public func fetchLists(for item: Item) {
//        fetchListsSubscription = listsRepository.events
//            .compactMap { event -> [List]? in
//                guard case .fetched(let lists) = event else { return nil }
//                return lists
//            }
//            .sink { [weak self] in
//                let filteredLists = $0.filter { $0.id != item.listId }
//                self?.eventsSubject.send(.fetched(filteredLists))
//                self?.fetchListsSubscription = nil
//            }
//
//        listsRepository.fetchAll()
    }

    public func moveItem(_ item: Item, toList list: List) {
        moveItemSubscription = itemsRepository.events
            .compactMap { event -> Item? in
                guard case .updated(let item) = event else { return nil }
                return item
            }
            .filter { $0.listId == list.id }
            .sink { [weak self] in
                self?.eventsSubject.send(.moved($0, targetList: list))
                self?.moveItemSubscription = nil
            }

        itemsRepository.update(item.withListId(list.id))
    }
}
