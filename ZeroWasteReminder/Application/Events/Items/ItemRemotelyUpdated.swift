public struct ItemRemotelyUpdated: AppEvent {
    public let itemId: Id<Item>

    public init(_ itemId: Id<Item>) {
        self.itemId = itemId
    }
}

extension ItemRemotelyUpdated {
    public var description: String {
        "\(name)(id: \(itemId.asString))"
    }
}
