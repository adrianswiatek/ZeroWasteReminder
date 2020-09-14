import Combine
import Foundation

public final class EventDispatcher {
    public var events: AnyPublisher<AppEvent, Never> {
        eventsSubject.share()
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    private let eventsSubject: PassthroughSubject<AppEvent, Never> = .init()

    public func dispatch(_ event: AppEvent) {
        eventsSubject.send(event)
    }
}
