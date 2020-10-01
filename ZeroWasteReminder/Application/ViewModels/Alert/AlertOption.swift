import Foundation

public enum AlertOption: Hashable {
    case none
    case onDayOfExpiration
    case daysBefore(_ days: Int)
    case weeksBefore(_ weeks: Int)
    case monthsBefore(_ months: Int)
    case customDate(_ date: Date)

    var formatted: String {
        switch self {
        case .none:
            return "None"
        case .onDayOfExpiration:
            return "On day of expiration"
        case .daysBefore(let days):
            return "\(days) \(days == 1 ? "day" : "days") before"
        case .weeksBefore(let weeks):
            return "\(weeks) \(weeks == 1 ? "week" : "weeks") before"
        case .monthsBefore(let months):
            return "\(months) \(months == 1 ? "month" : "months") before"
        case .customDate: return "Date"
        }
    }
}
