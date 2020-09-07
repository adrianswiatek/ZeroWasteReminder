import Combine
import Foundation

public final class InMemoryItemsRepository: ItemsRepository {
    private var items = [Item]()
    private let eventBus: EventBus

    public init(eventBus: EventBus) {
        self.eventBus = eventBus
    }

    public func fetchAll(from list: List) {
        let items = self.items
            .filter { $0.listId == list.id }
            .map { $0 }

        eventBus.send(ItemsFetchedEvent(items))
    }

    public func add(_ itemToSave: ItemToSave) {
        items.append(itemToSave.item)
        eventBus.send(ItemAddedEvent(itemToSave.item))
    }

    public func update(_ item: Item) {
        internalUpdate(item)
        eventBus.send(ItemUpdatedEvent(item))
    }

    public func move(_ item: Item, to list: List) {
        internalUpdate(item.withListId(list.id))
        eventBus.send(ItemMovedEvent(item, to: list))
    }

    public func remove(_ item: Item) {
        internalRemove(item)
        eventBus.send(ItemsRemovedEvent(item))
    }

    public func remove(_ items: [Item]) {
        items.forEach { internalRemove($0) }
        eventBus.send(ItemsRemovedEvent(items))
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
