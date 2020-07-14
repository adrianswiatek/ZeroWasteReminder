import Foundation

public struct List: Identifiable, Hashable {
    public let id: UUID
    public let name: String

    public func withName(_ name: String) -> List {
        .init(id: id, name: name)
    }
}

extension List {
    public init(name: String) {
        self.init(id: UUID(), name: name)
    }
}
