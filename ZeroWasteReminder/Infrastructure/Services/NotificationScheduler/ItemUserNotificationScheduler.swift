import Combine
import UserNotifications

public final class ItemUserNotificationScheduler: ItemNotificationsScheduler {
    private let requestFactory: ItemNotificationRequestFactory
    private let notificationRepository: ItemNotificationsRepository
    private let userNotificationCenter: UNUserNotificationCenter
    private let eventDispatcher: EventDispatcher

    public init(
        userNotificationRequestFactory: ItemNotificationRequestFactory,
        notificationRepository: ItemNotificationsRepository,
        userNotificationCenter: UNUserNotificationCenter,
        eventDispatcher: EventDispatcher
    ) {
        self.requestFactory = userNotificationRequestFactory
        self.notificationRepository = notificationRepository
        self.userNotificationCenter = userNotificationCenter
        self.eventDispatcher = eventDispatcher
    }

    public func scheduleNotification(for items: [Item]) {
        for item in items {
            guard let request = requestForItem(item) else { continue }
            userNotificationCenter.add(request)
            notificationRepository.update(for: item)
        }
    }

    public func removeScheduledNotification(for items: [Item]) {
        let ids = items.map { $0.id }

        notificationRepository.remove(by: ids)
        userNotificationCenter.removePendingNotificationRequests(withIdentifiers: ids.map { $0.asString })
    }

    public func removeScheduledNotificationForItems(in list: List) {
        let identifiers = notificationRepository.fetchAll(from: list).map { $0.itemId.asString }
        userNotificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
        notificationRepository.remove(by: list.id)
    }

    private func requestForItem(_ item: Item) -> UNNotificationRequest? {
        guard requestFactory.canCreate(for: .fromItem(item)) else {
            removeScheduledNotification(for: .just(item))
            return nil
        }

        return requestFactory.create(for: .fromItem(item))
    }
}
