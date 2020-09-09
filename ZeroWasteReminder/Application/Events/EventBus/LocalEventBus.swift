import Combine
import Foundation

public final class LocalEventBus: EventBus {
    public var events: AnyPublisher<AppEvent, Never> {
        eventsSubject.share().receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }

    private let eventsSubject: PassthroughSubject<AppEvent, Never>

    public init() {
        eventsSubject = .init()
    }

    public func send(_ event: AppEvent) {
        eventsSubject.send(event)
    }
}
