import Combine
import Foundation

public final class InMemoryItemsRepository: ItemsRepository {
    private let eventsSubject = PassthroughSubject<ItemsEvent, Never>()
    public var events: AnyPublisher<ItemsEvent, Never> {
        eventsSubject.eraseToAnyPublisher()
    }

    private var items = [ItemToSave]()

    public func fetchAll(from list: List) -> Future<Void, ServiceError> {
        let items = self.items
            .filter { $0.listId == list.id }
            .map { $0.item }

        eventsSubject.send(.fetched(items))
        return .init { $0(.success(())) }
    }

    public func add(_ item: ItemToSave) -> Future<Void, ServiceError> {
        items.append(item)
        eventsSubject.send(.added(item.item))
        return .init { $0(.success(())) }
    }

    public func update(_ item: Item) -> Future<Void, ServiceError> {
        Future { [weak self] promise in
            guard let self = self, let index = self.items.firstIndex(where: { $0.item.id == item.id }) else {
                return promise(.success(()))
            }

            self.items[index] = ItemToSave(item: item, listId: self.items[index].listId)
            self.eventsSubject.send(.updated(item))
            promise(.success(()))
        }
    }

    public func remove(_ item: Item) -> Future<Void, ServiceError> {
        Future { [weak self] promise in
            self?.internalRemove(item)
            self?.eventsSubject.send(.removed([item]))
            promise(.success(()))
        }
    }

    public func remove(_ items: [Item]) -> Future<Void, ServiceError> {
        Future { [weak self] promise in
            self?.items.forEach { self?.internalRemove($0.item) }
            self?.eventsSubject.send(.removed(items))
            promise(.success(()))
        }
    }

    public func removeAll(from list: List) -> Future<Void, ServiceError> {
        Future { [weak self] promise in
            self?.items.removeAll { $0.listId == list.id }
            promise(.success(()))
        }
    }

    private func internalRemove(_ item: Item) {
        items.removeAll { $0.item.id == item.id }
    }
}
