import Combine

public final class InMemoryItemsService: ItemsService {
    public var items: AnyPublisher<[Item], Never> {
        itemsSubject.eraseToAnyPublisher()
    }

    private let itemsSubject = CurrentValueSubject<[Item], Never>([])

    public func add(_ item: Item) -> Future<Item, Never> {
        Future { [weak self] promise in
            guard let self = self else { return }
            self.itemsSubject.value = self.itemsSubject.value + [item]
            promise(.success(item))
        }
    }

    public func update(_ item: Item) -> Future<Item, Never> {
        Future { [weak self] promise in
            guard
                let self = self,
                let itemsIndex = self.itemsSubject.value.firstIndex(where: { $0.id == item.id })
            else { preconditionFailure("Unable to find index of given item") }

            self.itemsSubject.value[itemsIndex] = item
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
