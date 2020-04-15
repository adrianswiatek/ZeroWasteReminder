public extension PeriodType {
    static func fromIndex(_ index: Int) -> PeriodType {
        switch index {
        case Self.day.index: return .day
        case Self.month.index: return .month
        case Self.year.index: return .year
        default: preconditionFailure("Invalid index")
        }
    }

    var name: String {
        "\(self)"
    }

    var namePlural: String {
        "\(name)s"
    }

    var index: Int {
        switch self {
        case .day: return 0
        case .month: return 1
        case .year: return 2
        }
    }
}
