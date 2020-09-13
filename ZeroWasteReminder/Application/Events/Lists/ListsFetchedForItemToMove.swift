public struct ListsFetchedForItemToMove: AppEvent {
    public let lists: [List]
    public let item: Item

    public init(_ lists: [List], _ item: Item) {
        self.lists = lists
        self.item = item
    }
}

extension ListsFetchedForItemToMove {
    public var description: String {
        "\(name)(itemId: \(item.id.asString), listIds: \(lists.map(\.id.asString).joined(separator: ", ")))"
    }
}
