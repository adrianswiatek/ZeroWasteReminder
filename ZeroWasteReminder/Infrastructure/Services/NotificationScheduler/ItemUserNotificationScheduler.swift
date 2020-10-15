import Combine
import UserNotifications

public final class ItemUserNotificationScheduler: ItemNotificationScheduler {
    private let requestFactory: ItemNotificationRequestFactory
    private let identifierProvider: ItemNotificationIdentifierProvider
    private let userNotificationCenter: UNUserNotificationCenter
    private let eventDispatcher: EventDispatcher

    public init(
        userNotificationRequestFactory: ItemNotificationRequestFactory,
        itemNotificationIdentifierProvider: ItemNotificationIdentifierProvider,
        userNotificationCenter: UNUserNotificationCenter,
        eventDispatcher: EventDispatcher
    ) {
        self.requestFactory = userNotificationRequestFactory
        self.identifierProvider = itemNotificationIdentifierProvider
        self.userNotificationCenter = userNotificationCenter
        self.eventDispatcher = eventDispatcher
    }

    public func scheduleNotification(for items: [Item]) {
        for item in items {
            guard let request = requestForItem(item) else { continue }
            userNotificationCenter.add(request)
            eventDispatcher.dispatch(ItemNotificationScheduled(item))
        }
    }

    public func removeScheduledNotifications(for items: [Item]) {
        userNotificationCenter.removePendingNotificationRequests(
            withIdentifiers: items.map { identifierProvider.provide(from: $0) }
        )

        items.forEach { eventDispatcher.dispatch(ItemNotificationRemoved($0.id) )}
    }

    public func removeScheduledNotificationsForItems(in list: List) {
        userNotificationCenter.getPendingNotificationRequests { [weak self] requests in
            self?.userNotificationCenter.removePendingNotificationRequests(
                withIdentifiers: self?.filter(requests, by: list.id).map { $0.identifier } ?? []
            )
        }

        eventDispatcher.dispatch(ItemNotificationRemoved(list.id))
    }

    private func requestForItem(_ item: Item) -> UNNotificationRequest? {
        guard requestFactory.canCreate(for: item) else {
            removeScheduledNotifications(for: .just(item))
            return nil
        }

        return requestFactory.create(for: item)
    }

    private func filter(_ requests: [UNNotificationRequest], by listId: Id<List>) -> [UNNotificationRequest] {
        requests.filter { identifierProvider.is(listId, partOf: $0.identifier) }
    }
}
