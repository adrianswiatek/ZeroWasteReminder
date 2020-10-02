import Foundation

public struct Item: Identifiable, Hashable {
    public let id: Id<Item>
    public let name: String
    public let notes: String
    public let expiration: Expiration
    public let alertOption: AlertOption

    public let listId: Id<List>

    public func withName(_ name: String) -> Item {
        .init(id: id, name: name, notes: notes, expiration: expiration, alertOption: alertOption, listId: listId)
    }

    public func withExpiration(_ expiration: Expiration) -> Item {
        .init(id: id, name: name, notes: notes, expiration: expiration, alertOption: alertOption, listId: listId)
    }

    public func withExpirationDate(_ date: Date?) -> Item {
        if let date = date {
            return .init(id: id, name: name, notes: notes, expiration: .date(date), alertOption: alertOption, listId: listId)
        }
        return .init(id: id, name: name, notes: notes, expiration: .none, alertOption: alertOption, listId: listId)
    }

    public func withNotes(_ notes: String) -> Item {
        .init(id: id, name: name, notes: notes, expiration: expiration, alertOption: alertOption, listId: listId)
    }

    public func withListId(_ listId: Id<List>) -> Item {
        .init(id: id, name: name, notes: notes, expiration: expiration, alertOption: alertOption, listId: listId)
    }

    public func withAlertOption(_ alertOption: AlertOption) -> Item {
        .init(id: id, name: name, notes: notes, expiration: expiration, alertOption: alertOption, listId: listId)
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
