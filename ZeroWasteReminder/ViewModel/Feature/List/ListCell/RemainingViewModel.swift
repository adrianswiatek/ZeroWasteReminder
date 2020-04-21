import Foundation

public final class RemainingViewModel {
    public var formattedValue: String {
        switch state {
        case .notDefined:
            return ""
        case .stale:
            return "stale"
        case .lastDay:
            return "last day"
        case let .good(value, component):
            return component.format(forValue: value)
        }
    }

    public var state: RemainingState

    public init(_ item: Item) {
        self.state = .notDefined
        self.setState(basedOn: item.expiration)
    }

    private func setState(basedOn expiration: Expiration) {
        guard case .date(let date) = expiration else { return }

        let components = componentsBetweenCurrentDate(and: date)

        setupDays(for: components)
        setupMonths(for: components)
        setupYears(for: components)
    }

    private func componentsBetweenCurrentDate(and date: Date) -> DateComponents {
        Calendar.current.dateComponents(
            [.day, .month, .year],
            from: Calendar.current.startOfDay(for: Date()),
            to: Calendar.current.startOfDay(for: date)
        )
    }

    private func setupYears(for components: DateComponents) {
        guard let year = components.year else { return }

        if year > 0 {
            state = .good(value: year, component: .year)
        } else if year < 0 {
            state = .stale
        }
    }

    private func setupMonths(for components: DateComponents) {
        guard let month = components.month else { return }

        if month > 0 {
            state = .good(value: month, component: .month)
        } else if month < 0 {
            state = .stale
        }
    }

    private func setupDays(for components: DateComponents) {
        guard let day = components.day else { return }

        if day > 0 {
            state = .good(value: day, component: .day)
        } else if day == 0 {
            state = .lastDay
        } else {
            state = .stale
        }
    }
}

extension RemainingViewModel {
    public enum RemainingState {
        case notDefined
        case stale
        case lastDay
        case good(value: Int, component: RemainingComponent)
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
}
