public struct ItemMoved: AppEvent {
    public let item: Item
    public let targetList: List

    public init(_ item: Item, to list: List) {
        self.item = item
        self.targetList = list
    }
}
