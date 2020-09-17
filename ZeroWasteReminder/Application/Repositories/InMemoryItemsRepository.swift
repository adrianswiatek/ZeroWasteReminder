import Combine
import Foundation

public final class InMemoryItemsRepository: ItemsRepository {
    private var items = [Item]()
    private let eventDispatcher: EventDispatcher

    public init(eventDispatcher: EventDispatcher) {
        self.eventDispatcher = eventDispatcher
    }

    public func fetchAll(from list: List) {
        let items = self.items
            .filter { $0.listId == list.id }
            .map { $0 }

        eventDispatcher.dispatch(ItemsFetched(items))
    }

    public func fetch(by id: Id<Item>) {
        items.first { $0.id == id }.map {
            eventDispatcher.dispatch(ItemFetched($0))
        }
    }

    public func add(_ itemToSave: ItemToSave) {
        items.append(itemToSave.item)
        eventDispatcher.dispatch(ItemAdded(itemToSave.item))
    }

    public func update(_ item: Item) {
        internalUpdate(item)
        eventDispatcher.dispatch(ItemUpdated(item))
    }

    public func move(_ item: Item, to list: List) {
        internalUpdate(item.withListId(list.id))
        eventDispatcher.dispatch(ItemMoved(item, to: list))
    }

    public func remove(_ item: Item) {
        internalRemove(item)
        eventDispatcher.dispatch(ItemsRemoved(item))
    }

    public func remove(_ items: [Item]) {
        items.forEach { internalRemove($0) }
        eventDispatcher.dispatch(ItemsRemoved(items))
    }

    private func internalUpdate(_ item: Item) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else {
            return
        }

        items[index] = item
    }

    private func internalRemove(_ item: Item) {
        items.removeAll { $0.id == item.id }
    }
}
