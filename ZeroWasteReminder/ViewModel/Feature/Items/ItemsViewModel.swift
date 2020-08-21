import Combine
import Foundation

public final class ItemsViewModel {
    @Published public var items: [Item]
    @Published public var modeState: ModeState
    @Published public var sortType: SortType
    @Published public var selectedItemIndices: [Int]

    public let isLoading: AnyPublisher<Bool, Never>
    public let requestsSubject: PassthroughSubject<Request, Never>

    public let list: List
    public let itemsFilterViewModel: ItemsFilterViewModel

    public var selectedItem: AnyPublisher<Item, Never> {
        selectedItemSubject.eraseToAnyPublisher()
    }

    public var canRemotelyConnect: AnyPublisher<Bool, Never> {
        statusNotifier.remoteStatus.map { $0 == .connected }.eraseToAnyPublisher()
    }

    private let selectedItemSubject: PassthroughSubject<Item, Never>

    private let itemsRepository: ItemsRepository
    private let statusNotifier: StatusNotifier
    private var subscriptions: Set<AnyCancellable>

    public init(list: List, itemsRepository: ItemsRepository, statusNotifier: StatusNotifier) {
        self.list = list

        let itemsRepositoryDecorator = ItemsRepositoryStateDecorator(itemsRepository)
        self.itemsRepository = itemsRepositoryDecorator
        self.isLoading = itemsRepositoryDecorator.isLoading
        self.statusNotifier = statusNotifier

        self.itemsFilterViewModel = .init()

        self.items = []
        self.modeState = ReadModeState()
        self.sortType = .ascending
        self.selectedItemIndices = []

        self.requestsSubject = .init()
        self.selectedItemSubject = .init()

        self.subscriptions = []

        self.bind()
    }

    public func cellViewModel(for item: Item) -> ItemsCellViewModel {
        .init(item, dateFormatter: .fullDateFormatter)
    }

    public func fetchItems() {
        itemsRepository.fetchAll(from: list)
    }

    public func deleteSelectedItems() {
        guard !selectedItemIndices.isEmpty else { return }

        let selectedItems = selectedItemIndices.map { items[$0] }
        itemsRepository.remove(selectedItems)

        modeState.done(on: self)
    }

    public func removeItem(_ item: Item) {
        itemsRepository.remove(item)
    }

    public func removeAll() {
        itemsRepository.remove(items)
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
        itemsRepository.events
            .compactMap { [weak self] in self?.updatedWithEvent($0) }
            .flatMap { Just($0).eraseToAnyPublisher() }
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

    private func updatedWithEvent(_ event: ItemsEvent) -> [Item] {
        var updatedItems = items

        switch event {
        case .added(let item):
            updatedItems += [item]
        case .error(let error):
            requestsSubject.send(.showErrorMessage(error.localizedDescription))
        case .fetched(let items):
            updatedItems = items
        case .removed(let items):
            items.forEach { item in updatedItems.removeAll { item.id == $0.id } }
        case .updated(let item):
            updatedItems.firstIndex { $0.id == item.id }.map { updatedItems[$0] = item }
        }

        return updatedItems
    }
}

public extension ItemsViewModel {
    enum Request: Equatable {
        case disableLoadingIndicatorOnce
        case removeItem(_ item: Item)
        case showErrorMessage(_ message: String)
    }
}
