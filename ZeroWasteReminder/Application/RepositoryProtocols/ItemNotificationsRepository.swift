public protocol ItemNotificationsRepository {
    func fetchAll(from list: List) -> [Notification]
    func fetch(for item: Item) -> Notification?
    func update(in item: Item)
    func remove(by itemId: Id<Item>)
    func remove(by listId: Id<List>)
}
