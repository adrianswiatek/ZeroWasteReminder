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
            removeScheduledNotifications(for: .just(item))
            return nil
        }

        return UNNotificationRequest(
            identifier: item.id.asString,
            content: contentForItem(item),
            trigger: triggerForItem(item)
        )
    }

    private func canCreateRequestForItem(_ item: Item) -> Bool {
        item.expiration.date.flatMap { item.alertOption.calculateDate(from: $0)?.isInTheFuture() } ?? false
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
        guard let expirationDate = item.expiration.date else { return nil }
        return calendarTriggerFromDate(item.alertOption.calculateDate(from: expirationDate))
    }

    private func calendarTriggerFromDate(_ date: Date?) -> UNCalendarNotificationTrigger? {
        date.map { $0.settingTime(hour: 9) }
            .map { Date.later($0, Date()) }
            .map { Calendar.current.dateComponents([.year, .month, .day, .hour], from: $0) }
            .map { .init(dateMatching: $0, repeats: false) }
    }
}
