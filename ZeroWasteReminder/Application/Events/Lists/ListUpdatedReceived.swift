public struct ListUpdatedReceived: AppEvent {
    public let listId: Id<List>

    public init(_ listId: Id<List>) {
        self.listId = listId
    }
}

extension ListUpdatedReceived {
    public var description: String {
        "\(name)(id: \(listId.asString))"
    }
}
