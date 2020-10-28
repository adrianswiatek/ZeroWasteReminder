import Combine
import Foundation

public protocol ItemsReadRepository {
    func fetchAll(from list: List) -> Future<[Item], Never>
    func fetch(by id: Id<Item>) -> Future<Item?, Never>
    func fetch(by searchTerm: String) -> Future<[Item], Never>
}
