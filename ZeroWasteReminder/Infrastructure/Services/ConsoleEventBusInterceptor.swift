import Combine

public final class ConsoleEventDispatcherInterceptor: EventDispatcherInterceptor {
    private let eventDispatcher: EventDispatcher
    private var cancellable: AnyCancellable?

    public required init(_ eventDispatcher: EventDispatcher) {
        self.eventDispatcher = eventDispatcher
    }

    public func startIntercept() {
        cancellable = eventDispatcher.events.sink {
            print("Event sent:", $0.description)
        }
    }

    public func stopIntercept() {
        cancellable?.cancel()
    }
}
