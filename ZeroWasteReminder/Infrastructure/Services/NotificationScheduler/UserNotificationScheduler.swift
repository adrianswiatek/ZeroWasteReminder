import Combine
import UserNotifications

public final class UserNotificationScheduler: NotificationScheduler {
    private let userNotificationCenter: UNUserNotificationCenter

    public init(userNotificationCenter: UNUserNotificationCenter) {
        self.userNotificationCenter = userNotificationCenter
    }

    public func scheduleNotification(for items: [Item]) {
        items.forEach {
            requestForItem($0).map { userNotificationCenter.add($0) }
        }
    }

    public func removeScheduledNotifications(for items: [Item]) {
        userNotificationCenter.removePendingNotificationRequests(
            withIdentifiers: items.map { $0.id.asString }
        )
    }

    private func requestForItem(_ item: Item) -> UNNotificationRequest? {
        guard canCreateRequestForItem(item) else {
            return nil
        }

        return UNNotificationRequest(
            identifier: item.id.asString,
            content: contentForItem(item),
            trigger: triggerForItem(item)
        )
    }

    private func canCreateRequestForItem(_ item: Item) -> Bool {
        item.expiration.date != nil
    }

    private func contentForItem(_ item: Item) -> UNNotificationContent {
        let content = UNMutableNotificationContent()
        content.body = "\(item.name) will expire \(item.expiration.date!)"
        return content
    }

    private func triggerForItem(_ item: Item) -> UNNotificationTrigger {
        guard let trigger = calendarTriggerFromItem(item) else {
            preconditionFailure("Trigger must not be nil.")
        }
        return trigger
    }

    private func calendarTriggerFromItem(_ item: Item) -> UNCalendarNotificationTrigger? {
        switch item.alertOption {
        case .none:
            return nil
        case .onDayOfExpiration:
            return calendarTriggerFromDate(item.expiration.date)
        case .daysBefore(let days):
            return calendarTriggerFromDate(item.expiration.date.map { $0.adding(-days, .day) })
        case .weeksBefore(let weeks):
            return calendarTriggerFromDate(item.expiration.date.map { $0.adding(-weeks * 7, .day) })
        case .monthsBefore(let months):
            return calendarTriggerFromDate(item.expiration.date.map { $0.adding(-months, .month) })
        case .customDate(let date):
            return calendarTriggerFromDate(date)
        }
    }

    private func calendarTriggerFromDate(_ date: Date?) -> UNCalendarNotificationTrigger? {
        date.map { $0.settingTime(hour: 9) }
            .map { Date.later($0, Date()) }
            .map { Calendar.current.dateComponents([.year, .month, .day, .hour], from: $0) }
            .map { .init(dateMatching: $0, repeats: false) }
    }
}
