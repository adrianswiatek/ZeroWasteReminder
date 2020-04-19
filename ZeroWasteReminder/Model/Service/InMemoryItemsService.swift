import Combine

public final class InMemoryItemsService: ItemsService {
    public var itemsUpdated: AnyPublisher<[Item], Never> {
        itemsUpdateSubject.eraseToAnyPublisher()
    }

    private let itemsUpdateSubject = CurrentValueSubject<[Item], Never>([])

    public func add(_ item: Item) -> AnyPublisher<Item, Never> {
        itemsUpdateSubject.value.append(item)
        return Just(item).eraseToAnyPublisher()
    }

    public func all() -> [Item] {
        itemsUpdateSubject.value
    }
}
