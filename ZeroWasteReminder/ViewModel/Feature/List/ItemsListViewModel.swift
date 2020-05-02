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

    private var subscriptions: Set<AnyCancellable>

    private let itemsSubject: CurrentValueSubject<[Item], Never>
    private let itemsService: ItemsService

    public init(itemsService: ItemsService) {
        self.itemsService = itemsService

        self.itemsFilterViewModel = .init()

        self.modeState = ReadModeState()
        self.sortType = .ascending
        self.selectedItemIndices = []

        self.itemsSubject = .init([])
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

    private func bind() {
        itemsService.items.combineLatest(itemsFilterViewModel.cellViewModels, $sortType)
            .compactMap { items, cells, sortType in
                let items = items.sorted(by: sortType.action())
                if cells.allSatisfy({ $0.isSelected == false }) {
                    return items
                }
                return cells.flatMap { $0.filter(items) }
            }
            .subscribe(itemsSubject)
            .store(in: &subscriptions)

        $modeState
            .sink { [weak self] _ in self?.selectedItemIndices = [] }
            .store(in: &subscriptions)
    }
}

public enum SortType {
    case ascending
    case descending

    public mutating func toggle() {
        self = self == .ascending ? .descending : .ascending
    }

    public func action() -> (Item, Item) -> Bool {
        switch self {
        case .ascending: return { $0 < $1 }
        case .descending: return { $0 > $1 }
        }
    }
}
