import Foundation

public struct Id<T>: Equatable, Hashable {
    private let uuid: UUID

    public static var empty: Id<T> {
        .init(uuid: .empty)
    }

    private init(uuid: UUID) {
        self.uuid = uuid
    }

    public static func fromUuid(_ uuid: UUID) -> Id<T> {
        .init(uuid: uuid)
    }

    public static func fromString(_ string: String) -> Id<T> {
        .init(uuid: UUID(uuidString: string)!)
    }

    public var asString: String {
        uuid.uuidString
    }

    public var asUuid: UUID {
        uuid
    }
}
