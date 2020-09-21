public struct PhotoRemovedReceived: AppEvent {
    public let photoId: Id<Photo>
    public let itemId: Id<Item>

    public init(_ photoId: Id<Photo>, _ itemId: Id<Item>) {
        self.photoId = photoId
        self.itemId = itemId
    }
}

extension PhotoRemovedReceived {
    public var description: String {
        "\(name)(id: \(photoId.asString), parentItemId: \(itemId.asString))"
    }
}
