import Combine
import UserNotifications

public final class ItemUserNotificationScheduler: ItemNotificationScheduler {
    private let requestFactory: ItemNotificationRequestFactory
    private let identifierProvider: ItemNotificationIdentifierProvider
    private let userNotificationCenter: UNUserNotificationCenter

    public init(
        userNotificationRequestFactory: ItemNotificationRequestFactory,
        itemNotificationIdentifierProvider: ItemNotificationIdentifierProvider,
        userNotificationCenter: UNUserNotificationCenter
    ) {
        self.requestFactory = userNotificationRequestFactory
        self.identifierProvider = itemNotificationIdentifierProvider
        self.userNotificationCenter = userNotificationCenter
    }

    public func scheduleNotification(for items: [Item]) {
        items.forEach {
            requestForItem($0).map { userNotificationCenter.add($0) }
        }
    }

    public func removeScheduledNotifications(for items: [Item]) {
        userNotificationCenter.removePendingNotificationRequests(
            withIdentifiers: items.map { identifierProvider.provide(from: $0) }
        )
    }

    private func requestForItem(_ item: Item) -> UNNotificationRequest? {
        guard requestFactory.canCreate(for: item) else {
            removeScheduledNotifications(for: .just(item))
            return nil
        }

        return requestFactory.create(for: item)
    }
}
