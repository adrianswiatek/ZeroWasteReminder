import Combine
import Foundation

public final class InMemoryItemsService: ItemsService {
    private let itemsRepository: ItemsRepository

    public init(itemsRepository: ItemsRepository) {
        self.itemsRepository = itemsRepository
    }

    public func add(_ item: Item) -> Future<Void, ServiceError> {
        Future { [weak self] promise in
            self?.itemsRepository.add(item)
            promise(.success(()))
        }
    }

    public func refresh() -> Future<Void, ServiceError> {
        Future { [weak self] promise in
            self.map { $0.itemsRepository.set($0.itemsRepository.allItems()) }
            promise(.success(()))
        }
    }

    public func update(_ item: Item) -> Future<Void, ServiceError> {
        Future { [weak self] promise in
            self?.itemsRepository.update(item)
            promise(.success(()))
        }
    }

    public func delete(_ items: [Item]) -> Future<Void, ServiceError> {
        Future { [weak self] promise in
            self?.itemsRepository.delete(items)
            promise(.success(()))
        }
    }

    public func deleteAll() -> Future<Void, ServiceError> {
        Future { [weak self] promise in
            self?.itemsRepository.deleteAll()
            promise(.success(()))
        }
    }
}
