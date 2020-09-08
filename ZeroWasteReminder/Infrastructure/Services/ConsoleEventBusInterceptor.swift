import Combine

public final class ConsoleEventBusInterceptor: EventBusInterceptor {
    private let eventBus: EventBus
    private var cancellable: AnyCancellable?

    public required init(_ eventBus: EventBus) {
        self.eventBus = eventBus
    }

    public func startIntercept() {
        cancellable = eventBus.events.sink { print($0.name) }
    }

    public func stopIntercept() {
        cancellable?.cancel()
    }
}
