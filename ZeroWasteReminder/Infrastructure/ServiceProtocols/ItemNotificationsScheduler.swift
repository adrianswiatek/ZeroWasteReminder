import Foundation

public protocol ItemNotificationsScheduler {
    func scheduleNotification(for items: [Item])
    func removeScheduledNotification(for items: [Item])
    func removeScheduledNotificationForItems(in list: List)
}
