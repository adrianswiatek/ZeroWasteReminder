import Combine

public final class InMemoryItemsService: ItemsService {
    public var items: AnyPublisher<[Item], Never> {
        itemsSubject.eraseToAnyPublisher()
    }

    private let itemsSubject = CurrentValueSubject<[Item], Never>([])

    public func add(_ item: Item) -> Future<Item, Never> {
        .init { [weak self] in
            self?.itemsSubject.value.append(item)
            $0(.success(item))
        }
    }

    public func delete(_ items: [Item]) {
        itemsSubject.value.removeAll { items.contains($0) }
    }

    public func deleteAll() {
        itemsSubject.value.removeAll()
    }

    public func all() -> [Item] {
        itemsSubject.value
    }
}
