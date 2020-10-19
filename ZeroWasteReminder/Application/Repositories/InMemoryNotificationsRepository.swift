public final class InMemoryNotificationsRepository: ItemNotificationsRepository {
    private var notifications: [ItemNotification] = []

    public func fetchAll() -> [ItemNotification] {
        notifications
    }

    public func fetchAll(from list: List) -> [ItemNotification] {
        notifications.filter { $0.listId == list.id }
    }

    public func fetch(for item: Item) -> ItemNotification? {
        notifications.first { $0.itemId == item.id }
    }

    public func update(for item: Item) {
        if let index = notifications.firstIndex(where: { $0.itemId == item.id }) {
            notifications.remove(at: index)
        }
        notifications.append(.fromItem(item))
    }

    public func remove(by itemIds: [Id<Item>]) {
        itemIds.forEach { itemId in notifications.removeAll { $0.itemId == itemId } }
    }

    public func remove(by itemId: Id<Item>) {
        notifications.removeAll { $0.itemId == itemId }
    }

    public func remove(by listId: Id<List>) {
        notifications.removeAll { $0.listId == listId }
    }
}
