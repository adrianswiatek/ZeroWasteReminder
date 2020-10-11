import Foundation

public enum AlertOption: Hashable {
    case none
    case onDayOfExpiration
    case daysBefore(_ days: Int)
    case weeksBefore(_ weeks: Int)
    case monthsBefore(_ months: Int)
    case customDate(_ date: Date)

    public func formatted(_ dateFormatter: DateFormatter) -> String {
        switch self {
        case .none:
            return .localized(.none)
        case .onDayOfExpiration:
            return .localized(.onDayOfExpiration)
        case .daysBefore(let days):
            return "\(days) \(days == 1 ? "day" : "days") before"
        case .weeksBefore(let weeks):
            return "\(weeks) \(weeks == 1 ? "week" : "weeks") before"
        case .monthsBefore(let months):
            return "\(months) \(months == 1 ? "month" : "months") before"
        case .customDate(let date):
            return dateFormatter.string(from: date)
        }
    }

    func calculateDate(from otherDate: Date) -> Date? {
        let otherDate = otherDate.settingTime(hour: 9)

        switch self {
        case .none: return nil
        case .onDayOfExpiration: return otherDate
        case .daysBefore(let days): return otherDate.adding(-days, .day)
        case .weeksBefore(let weeks): return otherDate.adding(-weeks * 7, .day)
        case .monthsBefore(let months): return otherDate.adding(-months, .month)
        case .customDate(let date): return date.settingTime(hour: 9)
        }
    }
}

extension AlertOption {
    public var asString: String {
        switch self {
        case .none: return ""
        case .onDayOfExpiration: return "0"
        case .daysBefore(let days): return "d\(days)"
        case .weeksBefore(let weeks): return "w\(weeks)"
        case .monthsBefore(let months): return "m\(months)"
        case .customDate(let date): return DateFormatter.withFormat(Constant.dateFormat).string(from: date)
        }
    }

    public static func fromString(_ option: String) -> AlertOption {
        if let date = DateFormatter.withFormat(Constant.dateFormat).date(from: option) {
            return .customDate(date)
        }

        switch option {
        case "0":
            return .onDayOfExpiration
        case let option where option.starts(with: "d"):
            return parseNumber(from: option).map { .daysBefore($0) } ?? .none
        case let option where option.starts(with: "w"):
            return parseNumber(from: option).map { .weeksBefore($0) } ?? .none
        case let option where option.starts(with: "m"):
            return parseNumber(from: option).map { .monthsBefore($0) } ?? .none
        default:
            return .none
        }
    }

    private static func parseNumber(from string: String) -> Int? {
        let firstIndex = string.index(string.startIndex, offsetBy: 1)
        return Int(string[firstIndex...])
    }

    private enum Constant {
        static let dateFormat: String = "yyyy-MM-dd"
    }
}
