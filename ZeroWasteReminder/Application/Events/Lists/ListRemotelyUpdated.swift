public struct ListRemotelyUpdated: AppEvent {
    public let listId: Id<List>

    public init(_ listId: Id<List>) {
        self.listId = listId
    }
}
