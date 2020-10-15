public struct Notification {
    public let itemId: Id<Item>
    public let listId: Id<List>
    public let alertOption: AlertOption
}

extension Notification: CustomStringConvertible {
    public var description: String {
        "Notification(id: \(itemId), withOption: \(alertOption.formatted(.longDate)))"
    }
}
