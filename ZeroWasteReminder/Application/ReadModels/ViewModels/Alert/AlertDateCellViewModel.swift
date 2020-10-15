import Combine
import Foundation

public final class AlertDateCellViewModel {
    @Published public var date: Date?
    @Published public var isCalendarShown: Bool

    private init(_ date: Date?) {
        self.date = date
        self.isCalendarShown = false
    }

    public static func fromAlertOption(_ option: AlertOption) -> AlertDateCellViewModel {
        if case .customDate(let date) = option {
            return .init(date)
        } else {
            return .init(nil)
        }
    }
}
