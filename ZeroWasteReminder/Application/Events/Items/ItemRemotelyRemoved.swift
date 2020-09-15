public struct ItemRemotelyRemoved: AppEvent {
    public let itemId: Id<Item>
    public let listId: Id<List>

    public init(_ itemId: Id<Item>, _ listId: Id<List>) {
        self.itemId = itemId
        self.listId = listId
    }
}

extension ItemRemotelyRemoved {
    public var description: String {
        "\(name)(id: \(itemId.asString))"
    }
}
