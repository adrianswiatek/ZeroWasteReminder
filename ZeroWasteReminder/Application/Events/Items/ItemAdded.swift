public struct ItemAdded: AppEvent {
    public let item: Item

    public init(_ item: Item) {
        self.item = item
    }
}

extension ItemAdded {
    public var description: String {
        "\(name)(id: \(item.id.asString))"
    }
}
