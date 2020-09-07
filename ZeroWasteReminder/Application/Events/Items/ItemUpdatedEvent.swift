public struct ItemUpdatedEvent {
    public let item: Item

    public init(_ item: Item) {
        self.item = item
    }
}
