public struct ItemNotificationRemoved<T>: AppEvent {
    public let id: Id<T>

    public init(_ id: Id<T>) {
        self.id = id
    }
}

extension ItemNotificationRemoved {
    public var description: String {
        "\(name)(id: \(id.asString))"
    }
}
