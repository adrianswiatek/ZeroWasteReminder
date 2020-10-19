import UserNotifications

public protocol ItemNotificationRequestFactory {
    func canCreate(for notificaiton: ItemNotification) -> Bool
    func create(for notification: ItemNotification) -> UNNotificationRequest
}
