public struct ListAddedReceived: AppEvent {
    public let listId: Id<List>

    public init(_ listId: Id<List>) {
        self.listId = listId
    }
}

extension ListAddedReceived {
    public var description: String {
        "\(name)(id: \(listId.asString))"
    }
}
