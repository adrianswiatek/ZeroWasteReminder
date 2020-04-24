import Combine

public final class InMemoryItemsService: ItemsService {
    public var items: AnyPublisher<[Item], Never> {
        itemsSubject.eraseToAnyPublisher()
    }

    private let itemsSubject = CurrentValueSubject<[Item], Never>([])

    public func add(_ item: Item) -> Future<Item, Never> {
        .init { [weak self] promise in
            guard let self = self else { return }

            let items = self.itemsSubject.value + [item]
            self.itemsSubject.value = items.sorted { $0 < $1 }

            promise(.success(item))
        }
    }

    public func delete(_ items: [Item]) {
        itemsSubject.value.removeAll { items.contains($0) }
    }

    public func deleteAll() {
        itemsSubject.value.removeAll()
    }
}
