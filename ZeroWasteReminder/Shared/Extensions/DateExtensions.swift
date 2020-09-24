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

    static func later(_ first: Date, _ second: Date) -> Date {
        first.compare(second) == .orderedDescending ? first : second
    }

    func addingDays(_ numberOfDays: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: numberOfDays, to: self) ?? self
    }

    func settingTime(hour: Int, minute: Int = 0, second: Int = 0) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(abbreviation: "UTC") ?? .current

        let result = calendar.date(bySettingHour: hour, minute: minute, second: second, of: self)
        return result ?? self
    }
}
