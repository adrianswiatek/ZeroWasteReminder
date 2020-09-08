import Combine
import Foundation

public final class ItemsViewModel {
    @Published public var items: [Item]
    @Published public var modeState: ModeState
    @Published public var sortType: SortType
    @Published public var selectedItemIndices: [Int]

    public var isLoading: AnyPublisher<Bool, Never> {
        isLoadingSubject.eraseToAnyPublisher()
    }

    public let requestsSubject: PassthroughSubject<Request, Never>

    public let list: List
    public let itemsFilterViewModel: ItemsFilterViewModel

    public var selectedItem: AnyPublisher<Item, Never> {
        selectedItemSubject.eraseToAnyPublisher()
    }

    public var canRemotelyConnect: AnyPublisher<Bool, Never> {
        statusNotifier.remoteStatus.map { $0 == .connected }.eraseToAnyPublisher()
    }

    private let isLoadingSubject: CurrentValueSubject<Bool, Never>
    private let selectedItemSubject: PassthroughSubject<Item, Never>

    private let itemsRepository: ItemsRepository
    private let statusNotifier: StatusNotifier
    private let eventBus: EventBus

    private var subscriptions: Set<AnyCancellable>

    public init(
        list: List,
        itemsRepository: ItemsRepository,
        statusNotifier: StatusNotifier,
        eventBus: EventBus
    ) {
        self.list = list

        self.itemsRepository = itemsRepository

        self.statusNotifier = statusNotifier
        self.eventBus = eventBus

        self.itemsFilterViewModel = .init()

        self.items = []
        self.modeState = ReadModeState()
        self.sortType = .ascending
        self.selectedItemIndices = []

        self.requestsSubject = .init()
        self.isLoadingSubject = .init(false)
        self.selectedItemSubject = .init()

        self.subscriptions = []

        self.bind()
    }

    public func cellViewModel(for item: Item) -> ItemsCellViewModel {
        .init(item, dateFormatter: .fullDateFormatter)
    }

    public func fetchItems() {
        itemsRepository.fetchAll(from: list)
        isLoadingSubject.send(true)
    }

    public func deleteSelectedItems() {
        guard !selectedItemIndices.isEmpty else { return }

        let selectedItems = selectedItemIndices.map { items[$0] }
        itemsRepository.remove(selectedItems)
        isLoadingSubject.send(true)

        modeState.done(on: self)
    }

    public func removeItem(_ item: Item) {
        itemsRepository.remove(item)
        isLoadingSubject.send(true)
    }

    public func removeAll() {
        itemsRepository.remove(items)
        isLoadingSubject.send(true)
    }

    public func filter() {
        modeState.filter(on: self)
    }

    public func sort() {
        sortType.toggle()
    }

    public func done() {
        modeState.done(on: self)
    }

    public func clear() {
        itemsFilterViewModel.deselectAll()
    }

    public func selectItem(at index: Int) {
        selectedItemSubject.send(items[index])
    }

    private func bind() {
        eventBus.events
            .compactMap { [weak self] in self?.updatedWithEvent($0) }
            .combineLatest(itemsFilterViewModel.cellViewModels, $sortType)
            .compactMap { items, cells, sortType in
                if cells.allSatisfy({ $0.isSelected == false }) {
                    return items.sorted(by: sortType.action())
                }
                return cells.flatMap { $0.filter(items) }.sorted(by: sortType.action())
            }
            .sink { [weak self] in self?.items = $0 }
            .store(in: &subscriptions)

        $modeState
            .sink { [weak self] _ in self?.selectedItemIndices = [] }
            .store(in: &subscriptions)
    }

    private func updatedWithEvent(_ event: AppEvent) -> [Item] {
        isLoadingSubject.send(false)

        var updatedItems = items

        switch event {
        case let event as ItemAddedEvent:
            updatedItems += [event.item]
        case let event as ItemsFetchedEvent:
            updatedItems = event.items
        case let event as ItemsRemovedEvent:
            event.items.forEach { item in updatedItems.removeAll { item.id == $0.id } }
        case let event as ItemUpdatedEvent:
            updatedItems.firstIndex { $0.id == event.item.id }.map { updatedItems[$0] = event.item }
        case let event as ItemMovedEvent:
            updatedItems = updatedItems.removedAll { $0.id == event.item.id }
        case let event as ErrorEvent:
            requestsSubject.send(.showErrorMessage(event.error.localizedDescription))
        default:
            return items
        }

        return updatedItems.removedAll { $0.listId != list.id }
    }
}

public extension ItemsViewModel {
    enum Request: Equatable {
        case disableLoadingIndicatorOnce
        case moveItem(_ item: Item)
        case removeItem(_ item: Item)
        case showErrorMessage(_ message: String)
    }
}
