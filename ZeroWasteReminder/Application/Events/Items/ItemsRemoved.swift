public struct ItemsRemoved: AppEvent {
    public let items: [Item]

    public init(_ items: [Item]) {
        self.items = items
    }

    public init(_ item: Item) {
        self.items = [item]
    }
}
