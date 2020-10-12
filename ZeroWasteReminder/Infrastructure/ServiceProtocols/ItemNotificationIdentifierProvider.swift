public protocol ItemNotificationIdentifierProvider {
    func provide(from item: Item) -> String
    func `is`(_ listId: Id<List>, partOf itemNotificationIdentifier: String) -> Bool
}
