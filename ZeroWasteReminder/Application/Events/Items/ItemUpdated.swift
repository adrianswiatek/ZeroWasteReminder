public struct ItemUpdated: AppEvent {
    public let item: Item

    public init(_ item: Item) {
        self.item = item
    }
}

extension ItemUpdated {
    public var description: String {
        "\(name)(id: \(item.id.asString))"
    }
}
