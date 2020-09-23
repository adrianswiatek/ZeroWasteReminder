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
    }

    private func whenAdded(_ items: [Item]) {
        items.forEach { userNotificationCenter.add(requestForItem($0)) }
    }

    private func whenRemoved(_ items: [Item]) {
        userNotificationCenter.removePendingNotificationRequests(
            withIdentifiers: items.map { $0.id.asString }
        )
    }

    private func whenUpdated(_ items: [Item]) {
        items.forEach { userNotificationCenter.add(requestForItem($0)) }
    }

    private func requestForItem(_ item: Item) -> UNNotificationRequest {
        return UNNotificationRequest(
            identifier: item.id.asString,
            content: contentForItem(item),
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        )
    }

    private func contentForItem(_ item: Item) -> UNNotificationContent {
        let content = UNMutableNotificationContent()
        content.body = "\(item.name) will expire soon"
        return content
    }
}
