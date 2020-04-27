import Combine
import Foundation

public final class ItemsListViewModel {
    @Published var mode: Mode
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

        self.mode = .read
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

        mode = .read
    }

    public func deleteAll() {
        itemsService.deleteAll()
    }

    private func bind() {
        itemsService.items.combineLatest(itemsFilterViewModel.cellViewModels)
            .compactMap { items, cells in
                if cells.allSatisfy({ $0.isSelected == false }) {
                    return items
                }
                return cells.flatMap { $0.filter(items) }
            }
            .subscribe(itemsSubject)
            .store(in: &subscriptions)
    }
}

extension ItemsListViewModel {
    public enum Mode {
        case read
        case selection
        case filtering
    }
}
