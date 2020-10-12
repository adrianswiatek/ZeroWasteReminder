public protocol ItemNotificationScheduler {
    func scheduleNotification(for items: [Item])
    func removeScheduledNotifications(for items: [Item])
    func removeScheduledNotificationsForItems(in list: List)
}
