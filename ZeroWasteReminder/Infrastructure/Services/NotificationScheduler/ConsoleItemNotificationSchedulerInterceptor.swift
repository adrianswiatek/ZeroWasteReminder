import UserNotifications

public final class ConsoleItemNotificationSchedulerInterceptor: ItemNotificationsScheduler {
    private let notificationScheduler: ItemNotificationsScheduler
    private let userNotificationCenter: UNUserNotificationCenter

    public init(
        notificationScheduler: ItemNotificationsScheduler,
        userNotificationCenter: UNUserNotificationCenter
    ) {
        self.notificationScheduler = notificationScheduler
        self.userNotificationCenter = userNotificationCenter

        self.logPendingNotifications()
    }

    public func scheduleNotification(for items: [Item]) {
        notificationScheduler.scheduleNotification(for: items)
        logPendingNotifications()
    }

    public func removeScheduledNotification(for items: [Item]) {
        notificationScheduler.removeScheduledNotification(for: items)
        logPendingNotifications()
    }

    public func removeScheduledNotificationForItems(in list: List) {
        notificationScheduler.removeScheduledNotificationForItems(in: list)

        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250)) {
            self.logPendingNotifications()
        }
    }

    private func logPendingNotifications() {
        userNotificationCenter.getPendingNotificationRequests { [weak self] in
            guard let stringifiedRequests = self?.stringifyRequests($0) else {
                return
            }

            print("Notifications:", stringifiedRequests)
        }
    }

    private func stringifyRequests(_ requests: [UNNotificationRequest]) -> [String] {
        requests.map {
            let itemId = $0.identifier
            let dateComponents = ($0.trigger as? UNCalendarNotificationTrigger).map { $0.dateComponents }!
            return "(id: \(itemId), \(dateComponents))"
        }
    }
}
