import Combine
import Foundation

public final class ListViewModel {
    @Published var isInSelectionMode: Bool
    @Published var selectedItemIndices: [Int]

    public var items: AnyPublisher<[Item], Never> {
        itemsSubject.eraseToAnyPublisher()
    }

    private var subscriptions: Set<AnyCancellable>

    private let itemsSubject: CurrentValueSubject<[Item], Never>
    private let itemsService: ItemsService

    public init(itemsService: ItemsService) {
        self.itemsService = itemsService

        self.isInSelectionMode = false
        self.selectedItemIndices = []

        self.itemsSubject = .init([])
        self.subscriptions = []

        self.bind()
    }

    public func cellViewModel(forItem item: Item) -> ListTableViewCellViewModel {
        .init(item, dateFormatter: .fullDateFormatter)
    }

    public func deleteSelectedItems() {
        guard !selectedItemIndices.isEmpty else { return }

        let selectedItems = selectedItemIndices.map { itemsSubject.value[$0] }
        itemsService.delete(selectedItems)

        isInSelectionMode = false
    }

    public func deleteAll() {
        itemsService.deleteAll()
    }

    private func bind() {
        itemsService.items
            .subscribe(itemsSubject)
            .store(in: &subscriptions)
    }
}
