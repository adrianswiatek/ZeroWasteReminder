import UserNotifications

public final class CalendarItemNotificationRequestFactory: ItemNotificationRequestFactory {
    public func canCreate(for notification: ItemNotification) -> Bool {
        notification.expiration.date.flatMap {
            notification.alertOption.calculateDate(from: $0)?.isInTheFuture()
        } ?? false
    }

    public func create(for notification: ItemNotification) -> UNNotificationRequest {
        return UNNotificationRequest(
            identifier: notification.itemId.asString,
            content: contentForNotification(notification),
            trigger: triggerForNotification(notification)
        )
    }

    private func contentForNotification(_ notification: ItemNotification) -> UNNotificationContent {
        configure(UNMutableNotificationContent()) {
            $0.title = "Alert"
            $0.body = bodyForNotification(notification)
            $0.userInfo = [
                "listId": notification.listId.asString,
                "alertOption": notification.alertOption.asString
            ]
        }
    }

    private func bodyForNotification(_ notification: ItemNotification) -> String {
        guard let expirationDate = notification.expiration.date else {
            preconditionFailure("Expiration date must not be nil.")
        }
        return notification.itemName + "will expire" + DateFormatter.longDate.string(from: expirationDate)
    }

    private func triggerForNotification(_ notification: ItemNotification) -> UNCalendarNotificationTrigger? {
        guard let expirationDate = notification.expiration.date else {
            preconditionFailure("Expiration date must not be nil.")
        }
        return calendarTriggerFromDate(notification.alertOption.calculateDate(from: expirationDate))
    }

    private func calendarTriggerFromDate(_ date: Date?) -> UNCalendarNotificationTrigger? {
        date.map { $0.settingTime(hour: 9) }
            .map { Date.later($0, Date()) }
            .map { Calendar.appCalendar.dateComponents([.year, .month, .day, .hour], from: $0) }
            .map { .init(dateMatching: $0, repeats: false) }
    }
}
