import Foundation

public struct Item: Identifiable, Hashable {
    public let id: Id<Item>
    public let name: String
    public let notes: String
    public let expiration: Expiration
    public let alertOption: AlertOption

    public let listId: Id<List>

    public static var empty: Item {
        .init(.empty, "", "", .none, .none, .empty)
    }

    public init(id: Id<Item>, name: String, listId: Id<List>) {
        self.init(id, name, "", .none, .none, listId)
    }

    private init(
        _ id: Id<Item>,
        _ name: String,
        _ notes: String,
        _ expiration: Expiration,
        _ alertOption: AlertOption,
        _ listId: Id<List>
    ) {
        self.id = id
        self.name = name
        self.notes = notes
        self.expiration = expiration
        self.alertOption = alertOption
        self.listId = listId
    }

    public func withName(_ name: String) -> Item {
        .init(id, name, notes, expiration, alertOption, listId)
    }

    public func withExpiration(_ expiration: Expiration) -> Item {
        .init(id, name, notes, expiration, alertOption, listId)
    }

    public func withExpirationDate(_ date: Date?) -> Item {
        if let date = date {
            return .init(id, name, notes, .date(date), alertOption, listId)
        }
        return .init(id, name, notes, .none, alertOption, listId)
    }

    public func withNotes(_ notes: String) -> Item {
        .init(id, name, notes, expiration, alertOption, listId)
    }

    public func withListId(_ listId: Id<List>) -> Item {
        .init(id, name, notes, expiration, alertOption, listId)
    }

    public func withAlertOption(_ alertOption: AlertOption) -> Item {
        var option = AlertOption.none

        if case .date(let date) = expiration, alertOption.calculateDate(from: date)?.isInTheFuture() == true {
            option = alertOption
        }

        return .init(id, name, notes, expiration, option, listId)
    }
}

extension Item: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
            && lhs.name == rhs.name
            && lhs.notes == rhs.notes
            && lhs.expiration == rhs.expiration
            && lhs.alertOption == rhs.alertOption
            && lhs.listId == rhs.listId
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
