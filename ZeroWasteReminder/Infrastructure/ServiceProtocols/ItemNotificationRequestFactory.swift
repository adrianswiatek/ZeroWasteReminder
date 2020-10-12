import UserNotifications

public protocol ItemNotificationRequestFactory {
    func canCreate(for item: Item) -> Bool
    func create(for item: Item) -> UNNotificationRequest
}
