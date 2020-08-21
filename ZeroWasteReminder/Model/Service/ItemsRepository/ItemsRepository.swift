import Combine
import Foundation

public protocol ItemsRepository {
    var events: AnyPublisher<ItemsEvent, Never> { get }

    func fetchAll(from list: List)
    func add(_ itemToSave: ItemToSave)
    func remove(_ item: Item)
    func remove(_ items: [Item])
    func update(_ item: Item)
}

public extension ItemsRepository {
    func nextId() -> Id<Item> {
        .fromUuid(.init())
    }
}
