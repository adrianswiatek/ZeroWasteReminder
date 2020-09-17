public struct ItemsFetched: AppEvent {
    public let items: [Item]

    public init(_ items: [Item]) {
        self.items = items
    }
}

extension ItemsFetched {
    public var description: String {
        "\(name)(ids: [\(items.map(\.id.asString).joined(separator: ", "))])"
    }
}
