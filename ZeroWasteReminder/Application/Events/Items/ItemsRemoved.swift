public struct ItemsRemoved: AppEvent {
    public let items: [Item]

    public init(_ items: [Item]) {
        self.items = items
    }

    public init(_ item: Item) {
        self.items = [item]
    }
}

extension ItemsRemoved {
    public var description: String {
        "\(name)(ids: [\(items.map { $0.id.asString }.joined(separator: ", "))])"
    }
}
