public protocol ItemNotificationsRepository {
    func fetchAll() -> [ItemNotification]
    func fetchAll(from list: List) -> [ItemNotification]
    func fetch(for item: Item) -> ItemNotification?
    func update(for item: Item)

    func remove(by itemIds: [Id<Item>])
    func remove(by itemId: Id<Item>)
    func remove(by listId: Id<List>)
}
