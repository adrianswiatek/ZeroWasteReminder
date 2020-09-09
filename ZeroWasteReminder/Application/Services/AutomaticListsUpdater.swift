import Combine
import Foundation

public final class DefaultAutomaticListUpdater: AutomaticListUpdater {
    private let listsRepository: ListsRepository
    private let eventBus: EventBus

    private var onItemChangeSubscription: AnyCancellable?
    private var onListChangeSubscription: AnyCancellable?

    public init(_ listsRepository: ListsRepository, _ eventBus: EventBus) {
        self.listsRepository = listsRepository
        self.eventBus = eventBus
    }

    public func startUpdating(_ list: List) {
        onItemChangeSubscription = eventBus.events
            .sink { [weak self] in self?.handleEvent($0, with: list) }
    }

    public func startUpdatingAllLists() {
        onListChangeSubscription = eventBus.events
            .filter { $0 is ListRemotelyUpdatedEvent }
            .sink { [weak self] _ in self?.listsRepository.fetchAll() }
    }

    private func handleEvent(_ event: AppEvent, with list: List) {
        switch event {
        case is ItemAddedEvent, is ItemUpdatedEvent, is ItemsRemovedEvent:
            update(list)
        case let event as ItemMovedEvent:
            update(list, event.targetList)
        default:
            break
        }
    }

    private func update(_ lists: List...) {
        listsRepository.update(lists.map {
            $0.withUpdateDate(Date())
        })
    }
}
