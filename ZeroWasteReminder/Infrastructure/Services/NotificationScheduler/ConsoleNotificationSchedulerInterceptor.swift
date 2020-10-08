import UserNotifications

public final class ConsoleNotificationSchedulerInterceptor: NotificationScheduler {
    private let notificationScheduler: NotificationScheduler
    private let userNotificationCenter: UNUserNotificationCenter

    public init(
        notificationScheduler: NotificationScheduler,
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

    public func removeScheduledNotifications(for items: [Item]) {
        notificationScheduler.removeScheduledNotifications(for: items)
        logPendingNotifications()
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
