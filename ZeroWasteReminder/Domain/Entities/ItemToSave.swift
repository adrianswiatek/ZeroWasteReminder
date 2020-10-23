public struct ItemToSave {
    public let item: Item
    public let list: List

    public init(_ item: Item, _ list: List) {
        self.item = item
        self.list = list
    }
}
