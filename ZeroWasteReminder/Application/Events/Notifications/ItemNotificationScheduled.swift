public struct ItemNotificationScheduled: AppEvent {
    public let item: Item

    public init(_ item: Item) {
        self.item = item
    }
}

extension ItemNotificationScheduled {
    public var description: String {
        "\(name)(id: \(item.id.asString), to: \(item.alertOption.formatted(.longDate)))"
    }
}
