import Combine

public protocol ListsRepository {
    func fetchAll() -> Future<[List], Never>
    func add(_ list: List)
    func remove(_ list: List)
    func update(_ lists: [List])
}

public extension ListsRepository {
    func nextId() -> Id<List> {
        .fromUuid(.init())
    }
}
