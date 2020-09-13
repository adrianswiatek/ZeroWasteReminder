public struct ListAdded: AppEvent {
    public let list: List

    public init(_ list: List) {
        self.list = list
    }
}

extension ListAdded {
    public var description: String {
        "\(name)(id: \(list.id.asString))"
    }
}
