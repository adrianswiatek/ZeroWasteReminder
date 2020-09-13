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
        notificationCenter.publisher(for: .listCreateReceived)
            .sink { [weak self] in
                guard let listId = self?.listId(from: $0) else { return }
                self?.dispatch(ListRemotelyCreated(listId))
            }
            .store(in: &subscriptions)

        notificationCenter.publisher(for: .listUpdateReceived)
            .sink { [weak self] in
                guard let listId = self?.listId(from: $0) else { return }
                self?.dispatch(ListRemotelyUpdated(listId))
            }
            .store(in: &subscriptions)

        notificationCenter.publisher(for: .listRemoveReceived)
            .sink { [weak self] in
                guard let listId = self?.listId(from: $0) else { return }
                self?.dispatch(ListRemotelyRemoved(listId))
            }
            .store(in: &subscriptions)
    }

    private func listId(from notification: Notification) -> Id<List>? {
        notification.userInfo?["id"].flatMap { $0 as? UUID }.map { Id<List>.fromUuid($0) }
    }
}
