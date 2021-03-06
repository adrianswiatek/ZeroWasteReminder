public struct ListsUpdated: AppEvent {
    public let lists: [List]

    public init(_ lists: [List]) {
        self.lists = lists
    }
}

extension ListsUpdated {
    public var description: String {
        "\(name)(ids: [\(lists.map(\.id.asString).joined(separator: ", "))])"
    }
}
