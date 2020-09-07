public struct ListsUpdatedEvent: AppEvent {
    public let lists: [List]

    public init(_ lists: [List]) {
        self.lists = lists
    }
}
