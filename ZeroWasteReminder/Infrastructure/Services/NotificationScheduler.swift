import Combine
import UserNotifications

public final class NotificationScheduler {
    private let eventDispatcher: EventDispatcher
    private let userNotificationCenter: UNUserNotificationCenter
    private var subscriptions: Set<AnyCancellable>

    public init(
        eventDispatcher: EventDispatcher,
        userNotificationCenter: UNUserNotificationCenter
    ) {
        self.eventDispatcher = eventDispatcher
        self.userNotificationCenter = userNotificationCenter
        self.subscriptions = []
        self.bind()

        self.userNotificationCenter.getPendingNotificationRequests {
            print($0.map { "\($0.identifier), \(($0.trigger as? UNCalendarNotificationTrigger).map { $0.dateComponents }!)" })
        }
    }

    private func bind() {
        eventDispatcher.events
            .sink { [weak self] in self?.handleEvent($0) }
            .store(in: &subscriptions)
    }

    private func handleEvent(_ event: AppEvent) {
        switch event {
        case let event as ItemAdded:
            whenAdded(.just(event.item))
        case let event as ItemsRemoved:
            whenRemoved(event.items)
        case let event as ItemUpdated:
            whenUpdated(.just(event.item))
        default:
            return
        }

        userNotificationCenter.getPendingNotificationRequests {
            print($0.map { "\($0.identifier), \(($0.trigger as? UNCalendarNotificationTrigger).map { $0.dateComponents }!)" })
        }
    }

    private func whenAdded(_ items: [Item]) {
        items.forEach { requestForItem($0).map { userNotificationCenter.add($0) } }
    }

    private func whenRemoved(_ items: [Item]) {
        userNotificationCenter.removePendingNotificationRequests(
            withIdentifiers: items.map { $0.id.asString }
        )
    }

    private func whenUpdated(_ items: [Item]) {
        items.forEach { requestForItem($0).map { userNotificationCenter.add($0) } }
    }

    private func requestForItem(_ item: Item) -> UNNotificationRequest? {
        guard canCreateRequestForItem(item) else {
            return nil
        }

        return UNNotificationRequest(
            identifier: item.id.asString,
            content: contentForItem(item),
            trigger: triggerForItem(item)
        )
    }

    private func canCreateRequestForItem(_ item: Item) -> Bool {
        item.expiration.date != nil
    }

    private func contentForItem(_ item: Item) -> UNNotificationContent {
        let content = UNMutableNotificationContent()
        content.body = "\(item.name) will expire soon"
        return content
    }

    private func triggerForItem(_ item: Item) -> UNNotificationTrigger {
        guard let trigger = calendarTriggerFromItem(item) else {
            preconditionFailure("Trigger must not be nil.")
        }
        return trigger
    }

    private func calendarTriggerFromItem(_ item: Item) -> UNCalendarNotificationTrigger? {
        item.expiration.date
            .map { $0.addingDays(-1).settingTime(hour: 9) }
            .map { Date.later($0, Date()) }
            .map { Calendar.current.dateComponents([.year, .month, .day, .hour], from: $0) }
            .map { UNCalendarNotificationTrigger(dateMatching: $0, repeats: false) }
    }
}
