import Combine
import UserNotifications

public final class NotificationScheduler {
    private let eventDispatcher: EventDispatcher
    private var subscriptions: Set<AnyCancellable>

    public init(eventDispatcher: EventDispatcher) {
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

    }

    private func whenRemoved(_ items: [Item]) {

    }

    private func whenUpdated(_ item: [Item]) {

    }
}
