public protocol AppEvent: CustomStringConvertible {
    var name: String { get }
}

extension AppEvent {
    public var name: String {
        String(describing: Self.self)
    }

    public var description: String {
        name
    }
}
