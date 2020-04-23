import Foundation

public struct Item: Identifiable, Hashable {
    public let id: UUID
    public let name: String
    public let expiration: Expiration

    public func withName(_ name: String) -> Item {
        .init(id: id, name: name, expiration: expiration)
    }

    public func withExpiration(_ expiration: Expiration) -> Item {
        .init(id: id, name: name, expiration: expiration)
    }
}

extension Item {
   public init(name: String, expiration: Expiration) {
        self.id = UUID()
        self.name = name
        self.expiration = expiration
    }
}

extension Item: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}
