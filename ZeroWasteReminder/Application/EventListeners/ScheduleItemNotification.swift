import Combine
import Foundation

public final class ScheduleItemNotification {
    private let notificationScheduler: ItemNotificationScheduler
    private let eventDispatcher: EventDispatcher
    private var subscriptions: Set<AnyCancellable>

    public init(
        _ notificationScheduler: ItemNotificationScheduler,
        _ eventDispatcher: EventDispatcher
    ) {
        self.notificationScheduler = notificationScheduler
        self.eventDispatcher = eventDispatcher
        self.subscriptions = []

        self.bind()
    }

    private func bind() {
        eventDispatcher.events
            .sink { [weak self] in self?.handleEvent($0) }
            .store(in: &subscriptions)
    }

    private func handleEvent(_ event: AppEvent) {
        switch event {
        case let event as ItemAdded:
            scheduleNotification(for: event.item)
        case let event as ItemUpdated:
            event.item.alertOption != .none
                ? scheduleNotification(for: event.item)
                : removeScheduledNotification(for: .just(event.item))
        case let event as ItemsRemoved:
            removeScheduledNotification(for: event.items)
        case let event as ListRemoved:
            removeScheduledNotificationForItems(in: event.list)
        default:
            return
        }
    }

    private func scheduleNotification(for item: Item) {
        notificationScheduler.scheduleNotification(for: .just(item))
    }

    private func removeScheduledNotification(for items: [Item]) {
        notificationScheduler.removeScheduledNotifications(for: items)
    }

    private func removeScheduledNotificationForItems(in list: List) {
        notificationScheduler.removeScheduledNotificationsForItems(in: list)
    }
}
