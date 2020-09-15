public struct ItemRemotelyAdded: AppEvent {
    public let itemId: Id<Item>
    public let listId: Id<List>

    public init(_ itemId: Id<Item>, _ listId: Id<List>) {
        self.itemId = itemId
        self.listId = listId
    }
}

extension ItemRemotelyAdded {
    public var description: String {
        "\(name)(id: \(itemId.asString))"
    }
}
