import Combine
import Foundation

public final class InMemoryItemsRepository: ItemsRepository {
    public var items: AnyPublisher<[Item], Never> {
        itemsSubject.receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }

    private let itemsSubject = CurrentValueSubject<[Item], Never>([])

    public func allItems() -> [Item] {
        itemsSubject.value
    }

    public func add(_ item: Item) {
        itemsSubject.value += [item]
    }

    public func set(_ items: [Item]) {
        itemsSubject.value = items
    }

    public func update(_ item: Item) {
        allItems()
            .firstIndex { $0.id == item.id }
            .map { itemsSubject.value[$0] = item }
    }

    public func delete(_ items: [Item]) {
        delete(items.map(\.id))
    }

    public func delete(_ itemIds: [UUID]) {
        itemsSubject.value.removeAll { itemIds.contains($0.id) }
    }

    public func deleteAll() {
        itemsSubject.value.removeAll()
    }
}
