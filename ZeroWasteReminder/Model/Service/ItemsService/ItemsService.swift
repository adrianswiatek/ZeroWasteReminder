import Combine

public protocol ItemsService {
    var items: AnyPublisher<[Item], Never> { get }

    @discardableResult
    func add(_ item: Item) -> Future<Void, ServiceError>

    @discardableResult
    func refresh() -> Future<Void, ServiceError>

    @discardableResult
    func update(_ item: Item) -> Future<Void, Never>

    @discardableResult
    func delete(_ items: [Item]) -> Future<Void, ServiceError>

    @discardableResult
    func deleteAll() -> Future<Void, ServiceError>
}
