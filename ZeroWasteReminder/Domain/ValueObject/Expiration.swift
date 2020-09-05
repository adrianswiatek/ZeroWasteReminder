import Foundation

public enum Expiration: Hashable {
    case none
    case date(_ date: Date)
}

extension Expiration: Equatable {
    public static func == (lhs: Expiration, rhs: Expiration) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none):
            return true
        case (.none, .date), (.date, .none):
            return false
        case let (.date(lhsDate), .date(rhsDate)):
            return Calendar.current.compare(lhsDate, to: rhsDate, toGranularity: .day) == .orderedSame
        }
    }
}

extension Expiration: Comparable {
    public static func < (lhs: Expiration, rhs: Expiration) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none):
            return false
        case (.none, .date):
            return true
        case (.date, .none):
            return false
        case let (.date(lhsDate), .date(rhsDate)):
            return Calendar.current.compare(lhsDate, to: rhsDate, toGranularity: .day) == .orderedAscending
        }
    }
}
