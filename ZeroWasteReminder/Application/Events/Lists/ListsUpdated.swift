public struct ListsUpdated: AppEvent {
    public let lists: [List]

    public init(_ lists: [List]) {
        self.lists = lists
    }
}