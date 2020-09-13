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
        notificationCenter
            .publisher(for: .listAddReceived)
            .merge(with: notificationCenter.publisher(for: .listRemoveReceived))
            .merge(with: notificationCenter.publisher(for: .listUpdateReceived))
            .sink { [weak self] in self?.handleListEvent($0) }
            .store(in: &subscriptions)

        notificationCenter
            .publisher(for: .itemAddReceived)
            .merge(with: notificationCenter.publisher(for: .itemRemoveReceived))
            .merge(with: notificationCenter.publisher(for: .itemUpdateReceived))
            .sink { [weak self] in self?.handleItemEvent($0) }
            .store(in: &subscriptions)
    }

    private func handleListEvent(_ notification: Notification) {
        guard let uuid = notification.userInfo?["id"] as? UUID else {
            preconditionFailure("Missing value for expected key 'id'.")
        }

        switch notification.name {
        case .listAddReceived: eventsSubject.send(ListRemotelyAdded(.fromUuid(uuid)))
        case .listRemoveReceived: eventsSubject.send(ListRemotelyRemoved(.fromUuid(uuid)))
        case .listUpdateReceived: eventsSubject.send(ListRemotelyUpdated(.fromUuid(uuid)))
        default: break
        }
    }

    private func handleItemEvent(_ notification: Notification) {
        guard let uuid = notification.userInfo?["id"] as? UUID else {
            preconditionFailure("Missing value for expected key 'id'.")
        }

        switch notification.name {
        case .itemAddReceived: eventsSubject.send(ItemRemotelyAdded(.fromUuid(uuid)))
        case .itemRemoveReceived: eventsSubject.send(ItemRemotelyRemoved(.fromUuid(uuid)))
        case .itemUpdateReceived: eventsSubject.send(ItemRemotelyUpdated(.fromUuid(uuid)))
        default: break
        }
    }
}
