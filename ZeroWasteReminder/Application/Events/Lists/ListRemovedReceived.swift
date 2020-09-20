public struct ListRemovedReceived: AppEvent {
    public let listId: Id<List>

    public init(_ listId: Id<List>) {
        self.listId = listId
    }
}

extension ListRemovedReceived {
    public var description: String {
        "\(name)(id: \(listId.asString))"
    }
}
