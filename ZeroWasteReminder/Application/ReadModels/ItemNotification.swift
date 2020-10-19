public struct ItemNotification {
    public let itemId: Id<Item>
    public let listId: Id<List>

    public let itemName: String
    public let expiration: Expiration
    public let alertOption: AlertOption

    public static func fromItem(_ item: Item) -> ItemNotification {
        ItemNotification(
            itemId: item.id,
            listId: item.listId,
            itemName: item.name,
            expiration: item.expiration,
            alertOption: item.alertOption
        )
    }
}

extension ItemNotification: CustomStringConvertible {
    public var description: String {
        "Notification(id: \(itemId), withOption: \(alertOption.formatted(.longDate)))"
    }
}
