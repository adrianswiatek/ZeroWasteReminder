public final class MoveItemViewModelFactory {
    private let moveItemService: MoveItemService
    private let eventDispatcher: EventDispatcher

    public init(moveItemService: MoveItemService, eventDispatcher: EventDispatcher) {
        self.moveItemService = moveItemService
        self.eventDispatcher = eventDispatcher
    }

    public func create(for item: Item) -> MoveItemViewModel {
        .init(item: item, moveItemService: moveItemService, eventDispatcher: eventDispatcher)
    }
}
