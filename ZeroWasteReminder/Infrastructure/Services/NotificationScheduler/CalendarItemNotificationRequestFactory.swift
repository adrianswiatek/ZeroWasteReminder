import UserNotifications

public final class CalendarItemNotificationRequestFactory: ItemNotificationRequestFactory {
    private let identifierProvider: ItemNotificationIdentifierProvider

    public init(identifierProvider: ItemNotificationIdentifierProvider) {
        self.identifierProvider = identifierProvider
    }

    public func canCreate(for item: Item) -> Bool {
        item.expiration.date.flatMap { item.alertOption.calculateDate(from: $0)?.isInTheFuture() } ?? false
    }

    public func create(for item: Item) -> UNNotificationRequest {
        .init(
            identifier: identifierProvider.provide(from: item),
            content: contentForItem(item),
            trigger: triggerForItem(item)
        )
    }

    private func contentForItem(_ item: Item) -> UNNotificationContent {
        let content = UNMutableNotificationContent()
        content.body = "\(item.name) will expire \(item.expiration.date!)"
        return content
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
