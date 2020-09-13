public struct ItemRemotelyAdded: AppEvent {
    public let itemId: Id<Item>

    public init(_ itemId: Id<Item>) {
        self.itemId = itemId
    }
}

extension ItemRemotelyAdded {
    public var description: String {
        "\(name)(id: \(itemId.asString))"
    }
}
