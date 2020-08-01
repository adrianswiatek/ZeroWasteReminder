import Combine
import Foundation

public protocol ItemsRepository {
    var events: AnyPublisher<ItemsEvent, Never> { get }

    @discardableResult
    func fetchAll(from list: List) -> Future<Void, ServiceError>

    @discardableResult
    func add(_ item: ItemToSave) -> Future<Void, ServiceError>

    @discardableResult
    func update(_ item: Item) -> Future<Void, ServiceError>

    @discardableResult
    func remove(_ item: Item) -> Future<Void, ServiceError>

    @discardableResult
    func remove(_ items: [Item]) -> Future<Void, ServiceError>

    @discardableResult
    func removeAll(from list: List) -> Future<Void, ServiceError>
}

public extension ItemsRepository {
    func nextId() -> Id<Item> {
        .fromUuid(.init())
    }
}
