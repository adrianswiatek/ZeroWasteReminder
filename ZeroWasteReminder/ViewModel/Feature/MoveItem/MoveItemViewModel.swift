import Combine

public final class MoveItemViewModel {
    public var canMoveItem: AnyPublisher<Bool, Never> {
        Just(false).share().eraseToAnyPublisher()
    }

    private let item: Item

    public init(item: Item) {
        self.item = item
    }
}
