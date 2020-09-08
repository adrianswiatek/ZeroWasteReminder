public protocol AppEvent {
    var name: String { get }
}

extension AppEvent {
    public var name: String {
        String(describing: Self.self)
    }
}
