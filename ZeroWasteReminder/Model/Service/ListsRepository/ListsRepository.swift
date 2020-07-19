import Combine

public protocol ListsRepository {
    var events: AnyPublisher<ListsEvent, Never> { get }

    func fetchAll()
    func add(_ list: List)
    func update(_ list: List)
    func remove(_ list: List)
}
