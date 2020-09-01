import Foundation

public struct List: Identifiable, Hashable {
    public let id: Id<List>
    public let name: String
    public let updateDate: Date

    public func withName(_ name: String) -> List {
        .init(id: id, name: name, updateDate: Date())
    }

    public func withDate(_ date: Date) -> List {
        .init(id: id, name: name, updateDate: date)
    }
}

extension List {
    public init(id: Id<List>, name: String) {
        self.id = id
        self.name = name
        self.updateDate = Date()
    }
}
