import Combine

public protocol MoveItemServiceProtocol {
    var events: AnyPublisher<MoveItemEvent, Never> { get }

    func fetchLists(for item: Item)
    func moveItem(_ item: Item, toList list: List)
}

public final class MoveItemService: MoveItemServiceProtocol {
    public var events: AnyPublisher<MoveItemEvent, Never> {
        eventsSubject.eraseToAnyPublisher()
    }

    private let eventsSubject: PassthroughSubject<MoveItemEvent, Never>

    private var fetchListsSubscription: AnyCancellable?
    private var moveItemSubscription: AnyCancellable?

    private let listsRepository: ListsRepository
    private let itemsRepository: ItemsRepository

    public init(_ listsRepository: ListsRepository, _ itemsRepository: ItemsRepository) {
        self.listsRepository = listsRepository
        self.itemsRepository = itemsRepository
        self.eventsSubject = .init()
    }

    public func fetchLists(for item: Item) {
        fetchListsSubscription = listsRepository.events
            .compactMap { event -> [List]? in
                guard case .fetched(let lists) = event else { return nil }
                return lists
            }
            .sink { [weak self] in
                let filteredLists = $0.filter { $0.id != item.listId }
                self?.eventsSubject.send(.fetched(filteredLists))
                self?.fetchListsSubscription = nil
            }

        listsRepository.fetchAll()
    }

    public func moveItem(_ item: Item, toList list: List) {
        moveItemSubscription = itemsRepository.events
            .compactMap { event -> Item? in
                guard case .updated(let item) = event else { return nil }
                return item
            }
            .filter { $0.listId == list.id }
            .sink { [weak self] in
                self?.eventsSubject.send(.moved($0))
                self?.moveItemSubscription = nil
            }

        itemsRepository.update(item.withListId(list.id))
    }
}
