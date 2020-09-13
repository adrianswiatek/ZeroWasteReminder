public struct ListsFetched: AppEvent {
    public let lists: [List]

    public init(_ lists: [List]) {
        self.lists = lists
    }
}

extension ListsFetched {
    public var description: String {
        "\(name)(ids: [\(lists.map { $0.id.asString }.joined(separator: ", "))])"
    }
}
