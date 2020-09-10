import Combine
import Foundation

public final class EventDispatcher {
    public var events: AnyPublisher<AppEvent, Never> {
        eventsSubject.share().receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }

    private let notificationCenter: NotificationCenter
    private let eventsSubject: PassthroughSubject<AppEvent, Never>
    private var subscriptions: Set<AnyCancellable>

    public init(_ notificationCenter: NotificationCenter) {
        self.notificationCenter = notificationCenter
        self.eventsSubject = .init()
        self.subscriptions = []

        self.bind()
    }

    public func dispatch(_ event: AppEvent) {
        eventsSubject.send(event)
    }

    private func bind() {
        notificationCenter.publisher(for: .listUpdateReceived)
            .sink { [weak self] _ in self?.dispatch(ListRemotelyUpdated()) }
            .store(in: &subscriptions)
    }
}
