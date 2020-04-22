import Combine
import Foundation

public final class ListViewModel {
    @Published var isInSelectionMode: Bool
    @Published var selectedItemIndices: [Int]

    public var numberOfItems: Int {
        itemsSubject.value.count
    }

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

    public func cell(forIndex index: Int) -> ListTableViewCellViewModel {
        .init(item(at: index), dateFormatter: .fullDateFormatter)
    }

    public func deleteSelectedItems() {
        guard !selectedItemIndices.isEmpty else { return }

        isInSelectionMode = false
        print("Delete items at indices: \(selectedItemIndices)")
    }

    public func deleteAll() {
        print("Delete all")
    }

    private func item(at index: Int) -> Item {
        guard index < numberOfItems else {
            preconditionFailure("No item at given index.")
        }

        return itemsSubject.value[index]
    }

    private func bind() {
        itemsService.itemsUpdated
            .subscribe(itemsSubject)
            .store(in: &subscriptions)
    }
}
