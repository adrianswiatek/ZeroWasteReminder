import Combine
import Foundation

public final class ItemsViewModel {
    @Published public var items: [Item]
    @Published public var modeState: ModeState
    @Published public var sortType: SortType
    @Published public var selectedItemIndices: [Int]
    @Published public var isViewOnTop: Bool

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
    private let needsToFetchSubject: PassthroughSubject<Bool, Never>

    private let itemsRepository: ItemsRepository
    private let statusNotifier: StatusNotifier
    private let updateListsDate: UpdateListsDate
    private let eventDispatcher: EventDispatcher

    private var subscriptions: Set<AnyCancellable>

    public init(
        list: List,
        itemsRepository: ItemsRepository,
        statusNotifier: StatusNotifier,
        updateListsDate: UpdateListsDate,
        eventDispatcher: EventDispatcher
    ) {
        self.list = list

        self.itemsRepository = itemsRepository
        self.statusNotifier = statusNotifier
        self.updateListsDate = updateListsDate
        self.eventDispatcher = eventDispatcher

        self.itemsFilterViewModel = .init()

        self.items = []
        self.modeState = ReadModeState()
        self.sortType = .ascending
        self.selectedItemIndices = []
        self.isViewOnTop = false

        self.requestsSubject = .init()
        self.isLoadingSubject = .init(false)
        self.selectedItemSubject = .init()
        self.needsToFetchSubject = .init()

        self.subscriptions = []

        self.updateListsDate.listen(in: list)
        self.bind()
    }

    deinit {
        updateListsDate.stopListening()
    }

    public func cellViewModel(for item: Item) -> ItemsCellViewModel {
        .init(item, dateFormatter: .fullDate)
    }

    public func fetchItems() {
        itemsRepository.fetchAll(from: list)
            .flatMap { [weak self] items -> AnyPublisher<[Item], Never> in
                guard let self = self else { return Empty().eraseToAnyPublisher() }
                return self.prepareToDisplay(Just(items).eraseToAnyPublisher())
            }
            .sink { [weak self] in
                self?.items = $0
                self?.isLoadingSubject.send(false)
            }
            .store(in: &subscriptions)

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
        eventDispatcher.events
            .compactMap { [weak self] in self?.updatedWithEvent($0) }
            .flatMap { [weak self] items -> AnyPublisher<[Item], Never> in
                guard let self = self else { return Empty().eraseToAnyPublisher() }
                return self.prepareToDisplay(Just(items).eraseToAnyPublisher())
            }
            .sink { [weak self] in
                self?.items = $0
                self?.isLoadingSubject.send(false);
            }
            .store(in: &subscriptions)

        eventDispatcher.events
            .sink { [weak self] in self?.handleRemoteEvent($0) }
            .store(in: &subscriptions)

        $modeState
            .sink { [weak self] _ in self?.selectedItemIndices = [] }
            .store(in: &subscriptions)

        Publishers.CombineLatest($isViewOnTop, needsToFetchSubject)
            .filter { $0.0 && $0.1 }
            .sink { [weak self] _ in
                self?.needsToFetchSubject.send(false)
                self?.fetchItems()
            }
            .store(in: &subscriptions)
    }

    private func updatedWithEvent(_ event: AppEvent) -> [Item] {
        var updatedItems = items

        switch event {
        case let event as ItemAdded:
            updatedItems += [event.item]
        case let event as ItemsRemoved:
            event.items.forEach { item in updatedItems.removeAll { item.id == $0.id } }
        case let event as ItemUpdated:
            updatedItems.firstIndex { $0.id == event.item.id }.map { updatedItems[$0] = event.item }
        case let event as ItemMoved:
            updatedItems = updatedItems.removedAll { $0.id == event.item.id }
        case let event as ListRemovedReceived where event.listId == list.id:
            requestsSubject.send(.dismiss)
        case let event as ErrorOccured:
            requestsSubject.send(.showErrorMessage(event.error.localizedDescription))
        default:
            return items
        }

        return updatedItems
    }

    private func handleRemoteEvent(_ event: AppEvent) {
        switch event {
        case let event as ItemAddedReceived where event.listId == list.id: fetchOrSchedule(delayInSeconds: 3)
        case let event as ItemRemovedReceived where event.listId == list.id: fetchOrSchedule()
        case let event as ItemUpdatedReceived where event.listId == list.id: fetchOrSchedule()
        default: return
        }
    }

    private func fetchOrSchedule(delayInSeconds: Int = 0) {
        if isViewOnTop {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delayInSeconds)) {
                self.fetchItems()
            }
        } else {
            needsToFetchSubject.send(true)
        }
    }

    private func prepareToDisplay(
        _ itemsPublisher: AnyPublisher<[Item], Never>
    ) -> AnyPublisher<[Item], Never> {
        itemsPublisher.combineLatest(itemsFilterViewModel.cellViewModels, $sortType)
            .map { items, cells, sortType -> [Item] in
                if cells.allSatisfy({ $0.isSelected == false }) {
                    return items.sorted(by: sortType.action())
                }
                return cells.flatMap { $0.filter(items) }.sorted(by: sortType.action())
            }
            .eraseToAnyPublisher()
    }
}

public extension ItemsViewModel {
    enum Request: Equatable {
        case disableLoadingIndicatorOnce
        case dismiss
        case moveItem(_ item: Item)
        case removeItem(_ item: Item)
        case showErrorMessage(_ message: String)
    }
}
