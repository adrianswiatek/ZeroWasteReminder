import Combine
import Foundation

public final class InMemoryItemsRepository {
    private var items = [Item]()
    private let eventDispatcher: EventDispatcher

    public init(eventDispatcher: EventDispatcher) {
        self.eventDispatcher = eventDispatcher
    }
}

extension InMemoryItemsRepository: ItemsReadRepository {
    public func fetchAll(from list: List) -> Future<[Item], Never> {
        Future { [weak self] promise in
            guard let self = self else { return promise(.success([])) }
            promise(.success(self.items.filter { $0.listId == list.id }))
        }
    }

    public func fetch(by id: Id<Item>) -> Future<Item?, Never> {
        Future { [weak self] in $0(.success(self?.items.first { $0.id == id })) }
    }

    public func fetch(by searchTerm: String) -> Future<[Item], Never> {
        Future { [weak self] promise in
            guard let self = self, !searchTerm.isEmpty else { return promise(.success([])) }

            let searchResult = self.items.filter { $0.name.lowercased().starts(with: searchTerm.lowercased()) }
            promise(.success(searchResult))
        }
    }
}

extension InMemoryItemsRepository: ItemsWriteRepository {
    public func add(_ itemToSave: ItemToSave) {
        items.append(itemToSave.item)
        eventDispatcher.dispatch(ItemAdded(itemToSave.item))
    }

    public func update(_ item: Item) {
        internalUpdate(item)
        eventDispatcher.dispatch(ItemUpdated(item))
    }

    public func move(_ item: Item, to list: List) {
        internalUpdate(item.withListId(list.id))
        eventDispatcher.dispatch(ItemMoved(item, to: list))
    }

    public func remove(_ item: Item) {
        internalRemove(item)
        eventDispatcher.dispatch(ItemsRemoved(item))
    }

    public func remove(_ items: [Item]) {
        items.forEach { internalRemove($0) }
        eventDispatcher.dispatch(ItemsRemoved(items))
    }

    private func internalUpdate(_ item: Item) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else {
            return
        }

        items[index] = item
    }

    private func internalRemove(_ item: Item) {
        items.removeAll { $0.id == item.id }
    }
}
