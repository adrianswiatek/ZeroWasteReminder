import Combine
import Foundation

public final class RemoteEventBus: EventBus {
    public var events: AnyPublisher<AppEvent, Never>

    private let eventBus: EventBus
    private let notificationCenter: NotificationCenter
    private var cancellable: AnyCancellable?

    public init(_ eventBus: EventBus, notificationCenter: NotificationCenter) {
        self.eventBus = eventBus
        self.events = eventBus.events
        self.notificationCenter = notificationCenter
        self.bind()
    }

    public func send(_ event: AppEvent) {
        eventBus.send(event)
    }

    private func bind() {
        cancellable = notificationCenter.publisher(for: .listUpdateReceived)
            .sink { [weak self] _ in self?.send(ListRemotelyUpdatedEvent()) }
    }
}
