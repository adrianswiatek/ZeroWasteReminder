public struct PhotosUpdated: AppEvent {
    public let itemId: Id<Item>

    public init(_ itemId: Id<Item>) {
        self.itemId = itemId
    }
}

extension PhotosUpdated {
    public var description: String {
        "\(name)(parentItemId: \(itemId.asString))"
    }
}
