import Combine

public protocol ListsRepository {
    @discardableResult
    func add(_ list: List) -> Future<Void, ServiceError>

    @discardableResult
    func refresh() -> Future<Void, ServiceError>

    @discardableResult
    func update(_ list: List) -> Future<Void, ServiceError>

    @discardableResult
    func delete(_ list: [List]) -> Future<Void, ServiceError>
}
