import Foundation

public enum Expiration {
    case none
    case date(_ date: Date)

    public static func fromPeriod(_ period: Int, ofType periodType: PeriodType) -> Expiration {
        .date(Date())
    }
}
