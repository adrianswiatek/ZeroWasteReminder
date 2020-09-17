public struct ListRemotelyAdded: AppEvent {
    public let listId: Id<List>

    public init(_ listId: Id<List>) {
        self.listId = listId
    }
}

extension ListRemotelyAdded {
    public var description: String {
        "\(name)(id: \(listId.asString))"
    }
}
