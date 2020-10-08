public protocol NotificationScheduler {
    func scheduleNotification(for items: [Item])
    func removeScheduledNotifications(for items: [Item])
}
