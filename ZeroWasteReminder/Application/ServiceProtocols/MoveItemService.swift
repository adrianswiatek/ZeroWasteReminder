import Combine

public protocol MoveItemService {
    func fetchLists(for item: Item)
    func moveItem(_ item: Item, to list: List)
}
