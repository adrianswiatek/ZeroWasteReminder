import Combine

public protocol MoveItemService {
    func fetchLists(for item: Item) -> AnyPublisher<[List], Never>
    func moveItem(_ item: Item, to list: List)
}
