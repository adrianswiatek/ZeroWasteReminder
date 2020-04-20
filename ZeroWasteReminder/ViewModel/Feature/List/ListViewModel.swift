import Combine

public final class ListViewModel {
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
        self.itemsSubject = .init([])
        self.subscriptions = []

        self.bind()
    }

    public func item(at index: Int) -> Item {
        guard index < numberOfItems else {
            preconditionFailure("No item at given index.")
        }

        return itemsSubject.value[index]
    }

    public func bind() {
        itemsService.itemsUpdated
            .subscribe(itemsSubject)
            .store(in: &subscriptions)
    }
}
