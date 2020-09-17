public struct ItemFetched: AppEvent {
    public let item: Item

    public init(_ item: Item) {
        self.item = item
    }
}

extension ItemFetched {
    public var description: String {
        "\(name)(id: \(item.id.asString))"
    }
}
