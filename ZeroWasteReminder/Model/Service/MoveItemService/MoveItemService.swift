import Combine

public protocol MoveItemRepository {
    var events: AnyPublisher<MoveItemEvent, Never> { get }

    func fetchLists(for item: Item)
    func moveItem(_ item: Item, toList list: List)
}

public final class InMemoryMoveItemRepository: MoveItemRepository {
    public var events: AnyPublisher<MoveItemEvent, Never> {
        eventsSubject.eraseToAnyPublisher()
    }

    private let eventsSubject: PassthroughSubject<MoveItemEvent, Never>
    private var subscriptions: Set<AnyCancellable>

    private let listsRepository: ListsRepository
    private let itemsRepository: ItemsRepository

    public init(_ listsRepository: ListsRepository, _ itemsRepository: ItemsRepository) {
        self.listsRepository = listsRepository
        self.itemsRepository = itemsRepository

        self.eventsSubject = .init()
        self.subscriptions = []

        self.bind()
    }

    public func fetchLists(for item: Item) {
        listsRepository.fetchAll()
    }

    public func moveItem(_ item: Item, toList list: List) {

    }

    private func bind() {
        listsRepository.events
            .compactMap { event -> [List]? in
                guard case .fetched(let lists) = event else { return nil }
                return lists
            }
            .sink { [weak self] in self?.eventsSubject.send(.fetched($0)) }
            .store(in: &subscriptions)

        itemsRepository.events
            .compactMap { event -> Item? in
                guard case .moved(let item) = event else { return nil }
                return item
            }
            .sink { [weak self] in self?.eventsSubject.send(.moved($0)) }
            .store(in: &subscriptions)
    }

    private func filteredLists
}
