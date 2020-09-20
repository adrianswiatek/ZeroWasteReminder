import Combine
import Foundation

public protocol ItemsRepository {
    func fetchAll(from list: List) -> Future<[Item], Never>
    func fetch(by id: Id<Item>) -> Future<Item?, Never>
    func add(_ itemToSave: ItemToSave)
    func update(_ item: Item)
    func move(_ item: Item, to list: List)
    func remove(_ item: Item)
    func remove(_ items: [Item])
}

public extension ItemsRepository {
    func nextId() -> Id<Item> {
        .fromUuid(.init())
    }
}
