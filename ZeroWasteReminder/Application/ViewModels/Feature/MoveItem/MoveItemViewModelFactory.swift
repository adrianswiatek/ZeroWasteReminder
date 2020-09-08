public final class MoveItemViewModelFactory {
    private let moveItemService: MoveItemService
    private let eventBus: EventBus

    public init(moveItemService: MoveItemService, eventBus: EventBus) {
        self.moveItemService = moveItemService
        self.eventBus = eventBus
    }

    public func create(for item: Item) -> MoveItemViewModel {
        .init(item: item, moveItemService: moveItemService, eventBus: eventBus)
    }
}
