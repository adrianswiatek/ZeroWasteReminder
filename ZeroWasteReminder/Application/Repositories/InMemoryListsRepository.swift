import Combine
import Foundation

public final class InMemoryListsRepository: ListsRepository {
    private var lists = [List]()
    private let eventDispatcher: EventDispatcher

    public init(eventDispatcher: EventDispatcher) {
        self.eventDispatcher = eventDispatcher
    }

    public func add(_ list: List) {
        lists.append(list)
        eventDispatcher.dispatch(ListAdded(list))
    }

    public func fetchAll() -> Future<[List], Never> {
        Future { [weak self] in $0(.success(self?.lists ?? [])) }
    }

    public func remove(_ list: List) {
        lists.removeAll { $0.id == list.id }
        eventDispatcher.dispatch(ListRemoved(list))
    }

    public func update(_ lists: [List]) {
        internalUpdate(lists)
        eventDispatcher.dispatch(ListsUpdated(lists))
    }

    private func internalUpdate(_ listsToUpdate: [List]) {
        listsToUpdate.forEach { list in
            lists.firstIndex { $0.id == list.id }.map { lists[$0] = list }
        }
    }
}
