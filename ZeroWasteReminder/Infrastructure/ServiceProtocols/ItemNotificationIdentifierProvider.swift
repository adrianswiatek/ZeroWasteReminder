public protocol ItemNotificationIdentifierProvider {
    func provide(from item: Item) -> String
}
