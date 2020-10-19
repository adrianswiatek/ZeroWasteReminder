import UserNotifications

public final class CalendarItemNotificationRequestFactory: ItemNotificationRequestFactory {
    public func canCreate(for item: Item) -> Bool {
        canCreate(for: .fromItem(item))
    }

    public func canCreate(for notification: ItemNotification) -> Bool {
        notification.expiration.date.flatMap {
            notification.alertOption.calculateDate(from: $0)?.isInTheFuture()
        } ?? false
    }

    public func create(for item: Item) -> UNNotificationRequest {
        create(for: .fromItem(item))
    }

    public func create(for notification: ItemNotification) -> UNNotificationRequest {
        UNNotificationRequest(
            identifier: notification.itemId.asString,
            content: contentForNotification(notification),
            trigger: triggerForNotification(notification)
        )
    }

    private func contentForNotification(_ notification: ItemNotification) -> UNNotificationContent {
        configure(UNMutableNotificationContent()) {
            $0.body = "\(notification.itemName) will expire \(notification.expiration.date!)"
            $0.userInfo = [
                "listId": notification.listId.asString,
                "alertOption": notification.alertOption.asString
            ]
        }
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
            .map { Calendar.current.dateComponents([.year, .month, .day, .hour], from: $0) }
            .map { .init(dateMatching: $0, repeats: false) }
    }
}
