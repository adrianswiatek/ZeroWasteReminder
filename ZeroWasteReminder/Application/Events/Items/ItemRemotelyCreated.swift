public struct ItemRemotelyAdded: AppEvent {
    public let item: Item

    public init(_ item: Item) {
        self.item = item
    }
}

extension ItemRemotelyAdded {
    public var description: String {
        "\(name)(id: \(item.id.asString))"
    }
}
