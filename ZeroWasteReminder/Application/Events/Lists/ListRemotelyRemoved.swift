public struct ListRemotelyRemoved: AppEvent {
    public let listId: Id<List>

    public init(_ listId: Id<List>) {
        self.listId = listId
    }
}

extension ListRemotelyRemoved {
    public var description: String {
        "\(name)(id: \(listId.asString))"
    }
}
