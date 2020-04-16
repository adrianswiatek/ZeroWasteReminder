import Foundation

public struct Period {
    public let value: Int
    public let type: PeriodType

    public var asDate: Date {
        switch type {
        case .day: return date(byAdding: .day)
        case .month: return date(byAdding: .month)
        case .year: return date(byAdding: .year)
        }
    }

    private func date(byAdding component: Calendar.Component) -> Date {
        guard let date = Calendar.current.date(byAdding: component, value: value, to: Date()) else {
            preconditionFailure("Unable to create date")
        }

        return date
    }
}
