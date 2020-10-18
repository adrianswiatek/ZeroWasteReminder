import UserNotifications

public final class CalendarItemNotificationRequestFactory: ItemNotificationRequestFactory {
    public func canCreate(for item: Item) -> Bool {
        item.expiration.date.flatMap { item.alertOption.calculateDate(from: $0)?.isInTheFuture() } ?? false
    }

    public func create(for item: Item) -> UNNotificationRequest {
        UNNotificationRequest(
            identifier: item.id.asString,
            content: contentForItem(item),
            trigger: triggerForItem(item)
        )
    }

    private func contentForItem(_ item: Item) -> UNNotificationContent {
        configure(UNMutableNotificationContent()) {
            $0.body = "\(item.name) will expire \(item.expiration.date!)"
            $0.userInfo = [
                "listId": item.listId.asString,
                "alertOption": item.alertOption.asString
            ]
        }
    }

    private func triggerForItem(_ item: Item) -> UNCalendarNotificationTrigger? {
        guard let expirationDate = item.expiration.date else {
            preconditionFailure("Expiration date must not be nil.")
        }
        return calendarTriggerFromDate(item.alertOption.calculateDate(from: expirationDate))
    }

    private func calendarTriggerFromDate(_ date: Date?) -> UNCalendarNotificationTrigger? {
        date.map { $0.settingTime(hour: 9) }
            .map { Date.later($0, Date()) }
            .map { Calendar.current.dateComponents([.year, .month, .day, .hour], from: $0) }
            .map { .init(dateMatching: $0, repeats: false) }
    }
}
