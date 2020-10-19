import UserNotifications

public protocol ItemNotificationRequestFactory {
    func canCreate(for item: Item) -> Bool
    func canCreate(for notificaiton: ItemNotification) -> Bool

    func create(for item: Item) -> UNNotificationRequest
    func create(for notification: ItemNotification) -> UNNotificationRequest
}
