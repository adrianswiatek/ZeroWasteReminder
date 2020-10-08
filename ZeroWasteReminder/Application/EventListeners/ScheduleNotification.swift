import Combine
import Foundation

public final class ScheduleNotification {
    private let notificationScheduler: NotificationScheduler
    private let eventDispatcher: EventDispatcher
    private var subscriptions: Set<AnyCancellable>

    public init(
        _ notificationScheduler: NotificationScheduler,
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
                : removeSchedulerNotification(for: .just(event.item))
        case let event as ItemsRemoved:
            removeSchedulerNotification(for: event.items)
        default:
            break
        }
    }

    private func scheduleNotification(for item: Item) {
        notificationScheduler.scheduleNotification(for: .just(item))
    }

    private func removeSchedulerNotification(for items: [Item]) {
        notificationScheduler.removeScheduledNotifications(for: items)
    }
}
