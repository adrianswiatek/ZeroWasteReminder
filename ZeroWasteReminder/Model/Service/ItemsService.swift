import Combine

public protocol ItemsService {
    var items: AnyPublisher<[Item], Never> { get }

    func add(_ item: Item) -> Future<Item, Never>
    func update(_ item: Item) -> Future<Item, Never>
    func delete(_ items: [Item])
    func deleteAll()
}
