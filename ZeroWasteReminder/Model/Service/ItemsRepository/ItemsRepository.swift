import Combine
import Foundation

public protocol ItemsRepository {
    var items: AnyPublisher<[Item], Never> { get }

    func allItems() -> [Item]

    func add(_ item: Item)
    func set(_ items: [Item])

    func update(_ item: Item)

    func delete(_ items: [Item])
    func delete(_ itemIds: [UUID])
    func deleteAll()
}
