public struct SearchItem: Hashable {
    public let item: Item
    public let list: List?

    public init(item: Item, list: List? = nil) {
        self.item = item
        self.list = list
    }

    public func withItem(_ item: Item) -> SearchItem {
        .init(item: item, list: list)
    }
}
