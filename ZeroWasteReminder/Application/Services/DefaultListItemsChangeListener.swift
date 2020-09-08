import Combine
import Foundation

public final class DefaultListItemsChangeListener: ListItemsChangeListener {
    public var updatedItemInList: AnyPublisher<[List], Never> {
        updatedItemInListSubject.eraseToAnyPublisher()
    }

    private let eventBus: EventBus

    private let updatedItemInListSubject: PassthroughSubject<[List], Never>
    private var subscriptions: Set<AnyCancellable>

    public init(eventBus: EventBus) {
        self.eventBus = eventBus

        self.updatedItemInListSubject = .init()
        self.subscriptions = []
    }

    public func startListeningForItemChange(in list: List) {
        eventBus.events
            .sink { [weak self] in self?.updateListIfNeeded(list, basedOn: $0) }
            .store(in: &subscriptions)
    }

    public func stopListening() {
        subscriptions = []
    }

    private func updateListIfNeeded(_ list: List, basedOn event: AppEvent) {
        switch event {
        case is ItemAddedEvent, is ItemUpdatedEvent, is ItemsRemovedEvent:
            updatedItemInListSubject.send([list])
        case let event as ItemMovedEvent:
            updatedItemInListSubject.send([list, event.targetList])
        default:
            break
        }
    }
}
