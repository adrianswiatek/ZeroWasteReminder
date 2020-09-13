public struct ListRemotelyCreated: AppEvent {
    public let listId: Id<List>

    public init(_ listId: Id<List>) {
        self.listId = listId
    }
}

extension ListRemotelyCreated {
    public var description: String {
        "\(name)(id: \(listId.asString))"
    }
}
