public struct ItemRemovedReceived: AppEvent {
    public let itemId: Id<Item>
    public let listId: Id<List>

    public init(_ itemId: Id<Item>, _ listId: Id<List>) {
        self.itemId = itemId
        self.listId = listId
    }
}

extension ItemRemovedReceived {
    public var description: String {
        "\(name)(id: \(itemId.asString), parentListId: \(listId.asString)"
    }
}
