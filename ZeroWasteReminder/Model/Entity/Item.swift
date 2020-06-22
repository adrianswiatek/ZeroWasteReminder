import Foundation

public struct Item: Identifiable, Hashable {
    public let id: UUID
    public let name: String
    public let notes: String
    public let expiration: Expiration

    public func withName(_ name: String) -> Item {
        .init(id: id, name: name, notes: notes, expiration: expiration)
    }

    public func withExpiration(_ expiration: Expiration) -> Item {
        .init(id: id, name: name, notes: notes, expiration: expiration)
    }

    public func withExpirationDate(_ date: Date?) -> Item {
        if let date = date {
            return .init(id: id, name: name, notes: notes, expiration: .date(date))
        }
        return .init(id: id, name: name, notes: notes, expiration: .none)
    }

    public func withNotes(_ notes: String) -> Item {
        .init(id: id, name: name, notes: notes, expiration: expiration)
    }
}

extension Item {
    public init(name: String, notes: String, expiration: Expiration, photos: [PhotoToSave]) {
        self.id = UUID()
        self.name = name
        self.notes = notes
        self.expiration = expiration
    }
}

extension Item: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
            && lhs.name == rhs.name
            && lhs.notes == rhs.notes
            && lhs.expiration == rhs.expiration
    }
}

extension Item: Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        if lhs.expiration == rhs.expiration {
            return lhs.name < rhs.name
        }

        return lhs.expiration < rhs.expiration
    }
}
