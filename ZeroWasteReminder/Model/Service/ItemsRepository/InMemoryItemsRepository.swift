import Combine
import Foundation

public final class InMemoryItemsRepository: ItemsRepository {
    private let eventsSubject = PassthroughSubject<ItemsEvent, Never>()
    public var events: AnyPublisher<ItemsEvent, Never> {
        eventsSubject.eraseToAnyPublisher()
    }

    private var items = [Item]()

    public func fetchAll(from list: List) {
        let items = self.items
            .filter { $0.listId == list.id }
            .map { $0 }

        eventsSubject.send(.fetched(items))
    }

    public func add(_ itemToSave: ItemToSave) {
        items.append(itemToSave.item)
        eventsSubject.send(.added(itemToSave.item))
    }

    public func update(_ item: Item) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else {
            return
        }

        items[index] = item
        eventsSubject.send(.updated(item))
    }

    public func remove(_ item: Item) {
        internalRemove(item)
        eventsSubject.send(.removed(item))
    }

    public func remove(_ items: [Item]) {
        items.forEach { internalRemove($0) }
        eventsSubject.send(.removed(items))
    }

    private func internalRemove(_ item: Item) {
        items.removeAll { $0.id == item.id }
    }
}
