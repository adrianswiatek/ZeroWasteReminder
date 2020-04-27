import Foundation

public enum RemainingState: Hashable {
    case notDefined
    case expired
    case almostExpired
    case valid(value: Int, component: RemainingComponent)

    public init(expiration: Expiration) {
        self = .notDefined

        guard case .date(let date) = expiration else {
            return
        }

        let components = componentsBetweenCurrentDate(and: date)

        if let year = components.year, year != 0 {
            self = stateBasedOn(.year, value: year)
        } else if let month = components.month, month != 0 {
            self = stateBasedOn(.month, value: month)
        } else if let day = components.day {
            self = stateBasedOn(.day, value: day)
        }
    }

    private func componentsBetweenCurrentDate(and date: Date) -> DateComponents {
        Calendar.current.dateComponents(
            [.day, .month, .year],
            from: Calendar.current.startOfDay(for: Date()),
            to: Calendar.current.startOfDay(for: date)
        )
    }

    private func stateBasedOn(_ component: RemainingComponent, value: Int) -> Self {
        if value > 0 { return .valid(value: value, component: component) }
        if value < 0 { return .expired }
        return .almostExpired
    }
}

extension RemainingState: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.notDefined, .notDefined), (.expired, .expired), (.almostExpired, .almostExpired):
            return true
        case let (.valid(lhsValue, lhsComponent), .valid(value: rhsValue, component: rhsComponent)):
            return lhsValue == rhsValue && lhsComponent == rhsComponent
        default:
            return false
        }
    }
}

public enum RemainingComponent {
    case unknown
    case day
    case month
    case year

    public func format(forValue value: Int) -> String {
        switch self {
        case .unknown:
            return ""
        case .month, .year:
            return "+\(value) \(self)\(value > 1 ? "s" : "")"
        case .day:
            return "\(value) \(self)\(value > 1 ? "s" : "")"
        }
    }
}
