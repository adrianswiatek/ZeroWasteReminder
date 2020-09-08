import Combine
import Foundation

public final class InMemoryListsRepository: ListsRepository {
    private var lists = [List]()
    private let eventBus: EventBus

    public init(eventBus: EventBus) {
        self.eventBus = eventBus
    }

    public func add(_ list: List) {
        lists.append(list)
        eventBus.send(ListAddedEvent(list))
    }

    public func fetchAll() {
        eventBus.send(ListsFetchedEvent(lists))
    }

    public func remove(_ list: List) {
        lists.removeAll { $0.id == list.id }
        eventBus.send(ListRemovedEvent(list))
    }

    public func update(_ list: List) {
        internalUpdate([list])
        eventBus.send(ListsUpdatedEvent([list]))
    }

    public func update(_ lists: [List]) {
        internalUpdate(lists)
        eventBus.send(ListsUpdatedEvent(lists))
    }

    private func internalUpdate(_ listsToUpdate: [List]) {
        listsToUpdate.forEach { list in
            lists.firstIndex { $0.id == list.id }.map { lists[$0] = list }
        }
    }
}
