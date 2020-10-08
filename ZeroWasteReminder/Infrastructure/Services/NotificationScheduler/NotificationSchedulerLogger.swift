import UserNotifications

public final class NotificationSchedulerLogDecorator: NotificationScheduler {
    private let notificationScheduler: NotificationScheduler
    private let userNotificationCenter: UNUserNotificationCenter
    private let log: ([String]) -> Void

    public init(
        notificationScheduler: NotificationScheduler,
        userNotificationCenter: UNUserNotificationCenter,
        log: @escaping ([String]) -> Void
    ) {
        self.notificationScheduler = notificationScheduler
        self.userNotificationCenter = userNotificationCenter
        self.log = log

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
        userNotificationCenter.getPendingNotificationRequests { [weak self] in self?.logRequests($0) }
    }

    private func logRequests(_ requests: [UNNotificationRequest]) {
        log(requests.map {
            "\($0.identifier), \(($0.trigger as? UNCalendarNotificationTrigger).map { $0.dateComponents }!)"
        })
    }
}
