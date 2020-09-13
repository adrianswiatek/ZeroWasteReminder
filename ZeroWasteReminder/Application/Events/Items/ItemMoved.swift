public struct ItemMoved: AppEvent {
    public let item: Item
    public let targetList: List

    public init(_ item: Item, to list: List) {
        self.item = item
        self.targetList = list
    }
}

extension ItemMoved {
    public var description: String {
        "\(name)(id: \(item.id.asString), targetListId: \(targetList.id.asString))"
    }
}
