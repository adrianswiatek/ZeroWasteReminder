public struct Item {
    public let name: String
    public let expiration: Expiration

    public static var empty: Item {
        .init(name: "", expiration: .none)
    }

    public init(name: String, expiration: Expiration) {
        self.name = name
        self.expiration = expiration
    }

    public func withName(_ name: String) -> Item {
        .init(name: name, expiration: expiration)
    }

    public func withExpiration(_ expiration: Expiration) -> Item {
        .init(name: name, expiration: expiration)
    }
}
