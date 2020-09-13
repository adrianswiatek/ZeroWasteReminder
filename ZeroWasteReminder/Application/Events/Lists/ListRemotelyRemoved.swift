public struct ListRemotelyRemoved: AppEvent {
    public let listId: Id<List>

    public init(_ listId: Id<List>) {
        self.listId = listId
    }
}
