public final class MixedItemNotificationIdentifierProvider: ItemNotificationIdentifierProvider {
    public func provide(from item: Item) -> String {
        let itemId = item.id.asString.split(separator: "-", maxSplits: 1)[0]
        let listId = item.listId.asString.split(separator: "-", maxSplits: 1)[0]
        return "\(itemId)+\(listId)"
    }
}
