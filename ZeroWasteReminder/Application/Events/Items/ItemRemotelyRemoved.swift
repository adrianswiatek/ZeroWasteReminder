public struct ItemRemotelyRemoved: AppEvent {
    public let itemId: Id<Item>

    public init(_ itemId: Id<Item>) {
        self.itemId = itemId
    }
}

extension ItemRemotelyRemoved {
    public var description: String {
        "\(name)(id: \(itemId.asString))"
    }
}
