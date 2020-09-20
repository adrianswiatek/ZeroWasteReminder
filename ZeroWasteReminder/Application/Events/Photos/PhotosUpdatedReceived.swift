public struct PhotosUpdatedReceived: AppEvent {
    public let itemId: Id<Item>

    public init(_ itemId: Id<Item>) {
        self.itemId = itemId
    }
}

extension PhotosUpdatedReceived {
    public var description: String {
        "\(name)(parentItemId: \(itemId.asString))"
    }
}
