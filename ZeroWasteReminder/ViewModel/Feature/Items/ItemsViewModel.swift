import Combine
import Foundation

public final class ItemsViewModel {
    @Published var modeState: ModeState
    @Published var sortType: SortType
    @Published var selectedItemIndices: [Int]

    public let list: List
    public let itemsFilterViewModel: ItemsFilterViewModel

    public var items: AnyPublisher<[Item], Never> {
        itemsSubject.eraseToAnyPublisher()
    }

    public var selectedItem: AnyPublisher<Item, Never> {
        selectedItemSubject.eraseToAnyPublisher()
    }

    public var canRemotelyConnect: AnyPublisher<Bool, Never> {
        statusNotifier.remoteStatus.map { $0 == .connected }.eraseToAnyPublisher()
    }

    public var needsDeleteItem: AnyPublisher<Item, Never> {
        needsDeleteItemSubject.eraseToAnyPublisher()
    }

    private let itemsSubject: CurrentValueSubject<[Item], Never>
    private let selectedItemSubject: PassthroughSubject<Item, Never>
    private let needsDeleteItemSubject: PassthroughSubject<Item, Never>

    private let itemsRepository: ItemsRepository
    private let statusNotifier: StatusNotifier
    private var subscriptions: Set<AnyCancellable>

    public init(list: List, itemsRepository: ItemsRepository, statusNotifier: StatusNotifier) {
        self.list = list

        self.itemsRepository = itemsRepository
        self.statusNotifier = statusNotifier

        self.itemsFilterViewModel = .init()

        self.modeState = ReadModeState()
        self.sortType = .ascending
        self.selectedItemIndices = []

        self.itemsSubject = .init([])
        self.selectedItemSubject = .init()
        self.needsDeleteItemSubject = .init()

        self.subscriptions = []

        self.bind()
    }

    public func cellViewModel(for item: Item) -> ItemsCellViewModel {
        .init(item, dateFormatter: .fullDateFormatter)
    }

    public func refreshList() -> Future<Void, ServiceError> {
        itemsRepository.fetchAll(from: list)
    }

    public func deleteSelectedItems() {
        guard !selectedItemIndices.isEmpty else { return }

        let selectedItems = selectedItemIndices.map { itemsSubject.value[$0] }
        itemsRepository.remove(selectedItems)

        modeState.done(on: self)
    }

    public func removeItem(_ item: Item) {
        itemsRepository.remove(item)
    }

    public func removeAll() {
        itemsRepository.removeAll(from: list)
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
        selectedItemSubject.send(itemsSubject.value[index])
    }

    public func setNeedsRemoveItem(at index: Int) {
        needsDeleteItemSubject.send(itemsSubject.value[index])
    }

    private func bind() {
        itemsRepository.events
            .compactMap { event -> [Item]? in
                guard case .fetched(let lists) = event else { return nil }
                return lists
            }
            .combineLatest(itemsFilterViewModel.cellViewModels, $sortType)
            .compactMap { items, cells, sortType in
                if cells.allSatisfy({ $0.isSelected == false }) {
                    return items.sorted(by: sortType.action())
                }
                return cells.flatMap { $0.filter(items) }.sorted(by: sortType.action())
            }
            .subscribe(itemsSubject)
            .store(in: &subscriptions)

        $modeState
            .sink { [weak self] _ in self?.selectedItemIndices = [] }
            .store(in: &subscriptions)
    }
}
