import Combine

public protocol ListsRepository {
    func fetchAll()
    func add(_ list: List)
    func remove(_ list: List)
    func update(_ list: List)
    func update(_ lists: [List])
}

public extension ListsRepository {
    func nextId() -> Id<List> {
        .fromUuid(.init())
    }
}
