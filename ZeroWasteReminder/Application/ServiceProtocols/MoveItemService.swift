import Combine

public protocol MoveItemService {
    var events: AnyPublisher<MoveItemEvent, Never> { get }

    func fetchLists(for item: Item)
    func moveItem(_ item: Item, toList list: List)
}
