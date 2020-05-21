import Combine
import Foundation

public final class ItemsListViewModel {
    @Published var modeState: ModeState
    @Published var sortType: SortType
    @Published var selectedItemIndices: [Int]

    public let itemsFilterViewModel: ItemsFilterViewModel

    public var items: AnyPublisher<[Item], Never> {
        itemsSubject.eraseToAnyPublisher()
    }

    public var selectedItem: AnyPublisher<Item, Never> {
        selectedItemSubject.eraseToAnyPublisher()
    }

    private let itemsSubject: CurrentValueSubject<[Item], Never>
    private let selectedItemSubject: PassthroughSubject<Item, Never>

    private let itemsService: ItemsService
    private var subscriptions: Set<AnyCancellable>

    public init(itemsService: ItemsService) {
        self.itemsService = itemsService

        self.itemsFilterViewModel = .init()

        self.modeState = ReadModeState()
        self.sortType = .ascending
        self.selectedItemIndices = []

        self.itemsSubject = .init([])
        self.selectedItemSubject = .init()

        self.subscriptions = []

        self.bind()
    }

    public func cellViewModel(forItem item: Item) -> ItemsListCellViewModel {
        .init(item, dateFormatter: .fullDateFormatter)
    }

    public func deleteSelectedItems() {
        guard !selectedItemIndices.isEmpty else { return }

        let selectedItems = selectedItemIndices.map { itemsSubject.value[$0] }
        itemsService.delete(selectedItems)

        modeState.done(on: self)
    }

    public func refreshList() -> Future<Void, ServiceError> {
        itemsService.refresh()
    }

    public func deleteAll() {
        itemsService.deleteAll()
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

    private func bind() {
        itemsService.items.combineLatest(itemsFilterViewModel.cellViewModels, $sortType)
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
