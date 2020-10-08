import Combine

public final class ConsoleEventDispatcherInterceptor: EventDispatcherInterceptor {
    private let eventDispatcher: EventDispatcher
    private var subscriptions: Set<AnyCancellable>

    public required init(eventDispatcher: EventDispatcher) {
        self.eventDispatcher = eventDispatcher
        self.subscriptions = []

        self.bind()
    }

    private func bind() {
        eventDispatcher.events
            .sink { print("Event sent:", $0.description) }
            .store(in: &subscriptions)
    }
}
