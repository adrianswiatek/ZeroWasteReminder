import Combine

public protocol ListsRepository {
    var lists: AnyPublisher<[List], Never> { get }

    @discardableResult
    func refresh() -> Future<Void, ServiceError>

    @discardableResult
    func add(_ list: List) -> Future<Void, ServiceError>

    @discardableResult
    func update(_ list: List) -> Future<Void, ServiceError>

    @discardableResult
    func remove(_ list: List) -> Future<Void, ServiceError>
}
