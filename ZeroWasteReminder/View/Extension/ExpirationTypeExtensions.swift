public extension ExpirationType {
    static func fromIndex(_ index: Int) -> ExpirationType {
        switch index {
        case Self.none.index: return .none
        case Self.date.index: return .date
        case Self.period.index: return .period
        default: preconditionFailure("Invalid index")
        }
    }

    var index: Int {
        switch self {
        case .none: return 0
        case .date: return 1
        case .period: return 2
        }
    }
}
