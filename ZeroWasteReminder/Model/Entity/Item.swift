import Foundation

public struct Item: Identifiable, Hashable {
    public let id: UUID
    public let name: String
    public let notes: String
    public let expiration: Expiration
    public let photos: [Photo]

    public func withName(_ name: String) -> Item {
        .init(id: id, name: name, notes: notes, expiration: expiration, photos: photos)
    }

    public func withExpiration(_ expiration: Expiration) -> Item {
        .init(id: id, name: name, notes: notes, expiration: expiration, photos: photos)
    }

    public func withExpirationDate(_ date: Date?) -> Item {
        if let date = date {
            return .init(id: id, name: name, notes: notes, expiration: .date(date), photos: photos)
        }
        return .init(id: id, name: name, notes: notes, expiration: .none, photos: photos)
    }

    public func withNotes(_ notes: String) -> Item {
        .init(id: id, name: name, notes: notes, expiration: expiration, photos: photos)
    }

    public func withPhotos(_ photos: [Photo] = []) -> Item {
        .init(id: id, name: name, notes: notes, expiration: expiration, photos: photos)
    }

    public func prependingPhoto(_ photo: Photo) -> Item {
        .init(id: id, name: name, notes: notes, expiration: expiration, photos: [photo] + photos)
    }
}

extension Item {
    public init(name: String, notes: String, expiration: Expiration, photos: [Photo]) {
        self.id = UUID()
        self.name = name
        self.notes = notes
        self.expiration = expiration
        self.photos = photos
    }
}

extension Item: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
            && lhs.name == rhs.name
            && lhs.notes == rhs.notes
            && lhs.expiration == rhs.expiration
            && lhs.photos == rhs.photos
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
