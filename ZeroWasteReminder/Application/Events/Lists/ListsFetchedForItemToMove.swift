public struct ListsFetchedForItemToMove: AppEvent {
    public let lists: [List]
    public let item: Item

    public init(_ lists: [List], _ item: Item) {
        self.lists = lists
        self.item = item
    }
}
