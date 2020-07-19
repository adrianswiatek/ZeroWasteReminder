import Foundation

public struct List: Identifiable, Hashable {
    public let id: UUID
    public let name: String
    public let updateDate: Date

    public func withName(_ name: String) -> List {
        .init(id: id, name: name, updateDate: Date())
    }
}

extension List {
    public init(name: String) {
        self.init(id: UUID(), name: name, updateDate: Date())
    }
}
