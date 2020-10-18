public protocol ItemNotificationsRepository {
    func fetchAll() -> [Notification]
    func fetchAll(from list: List) -> [Notification]
    func fetch(for item: Item) -> Notification?
    func update(for item: Item)

    func remove(by itemIds: [Id<Item>])
    func remove(by itemId: Id<Item>)
    func remove(by listId: Id<List>)
}
