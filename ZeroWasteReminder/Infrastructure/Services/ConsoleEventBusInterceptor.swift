import Combine

public final class ConsoleeventDispatcherInterceptor: EventDispatcherInterceptor {
    private let eventDispatcher: EventDispatcher
    private var cancellable: AnyCancellable?

    public required init(_ eventDispatcher: EventDispatcher) {
        self.eventDispatcher = eventDispatcher
    }

    public func startIntercept() {
        cancellable = eventDispatcher.events.sink { print($0.name) }
    }

    public func stopIntercept() {
        cancellable?.cancel()
    }
}
