import Combine

public protocol ItemsService {
    var itemsUpdated: AnyPublisher<[Item], Never> { get }

    func add(_ item: Item) -> AnyPublisher<Item, Never>
    func all() -> [Item]
}
