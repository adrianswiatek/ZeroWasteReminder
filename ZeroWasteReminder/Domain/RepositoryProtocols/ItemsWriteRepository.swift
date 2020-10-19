import Combine
import Foundation

public protocol ItemsWriteRepository {
    func add(_ itemToSave: ItemToSave)
    func update(_ item: Item)
    func move(_ item: Item, to list: List)
    func remove(_ item: Item)
    func remove(_ items: [Item])
}

public extension ItemsWriteRepository {
    func nextId() -> Id<Item> {
        .fromUuid(.init())
    }
}
