public enum SortType {
    case ascending
    case descending

    public mutating func toggle() {
        self = self == .ascending ? .descending : .ascending
    }

    public func action() -> (Item, Item) -> Bool {
        switch self {
        case .ascending: return { $0 < $1 }
        case .descending: return { $0 > $1 }
        }
    }
}
