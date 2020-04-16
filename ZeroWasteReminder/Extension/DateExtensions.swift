import Foundation

public extension Date {
    static func fromPeriod(_ period: Int, ofType periodType: PeriodType) -> Date {
        func date(byAdding component: Calendar.Component, value: Int) -> Date {
            guard let date = Calendar.current.date(byAdding: component, value: value, to: Date()) else {
                preconditionFailure("Unable to create date")
            }
            return date
        }

        switch periodType {
        case .day: return date(byAdding: .day, value: period)
        case .month: return date(byAdding: .month, value: period)
        case .year: return date(byAdding: .year, value: period)
        }
    }
}
