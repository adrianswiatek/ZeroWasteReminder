import Combine

public final class UpdatePersistedItemNotification {
    private let notificationRepository: ItemNotificationsRepository
    private let eventDispatcher: EventDispatcher

    private var subscriptions: Set<AnyCancellable>

    public init(
        notificationRepository: ItemNotificationsRepository,
        eventDispatcher: EventDispatcher
    ) {
        self.notificationRepository = notificationRepository
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
        case let event as ItemNotificationScheduled:
            notificationRepository.update(in: event.item)
        case let event as ItemNotificationRemoved<Item>:
            notificationRepository.remove(by: event.id)
        case let event as ItemNotificationRemoved<List>:
            notificationRepository.remove(by: event.id)
        default:
            return
        }
    }
}
