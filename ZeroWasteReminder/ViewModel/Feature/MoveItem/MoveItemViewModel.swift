import Combine

public final class MoveItemViewModel {
    public var canMoveItem: AnyPublisher<Bool, Never> {
        Just(false).share().eraseToAnyPublisher()
    }

    private let item: Item
    private let list: List

    public init(item: Item, list: List) {
        self.item = item
        self.list = list
    }
}
