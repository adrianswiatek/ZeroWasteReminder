public final class MoveItemViewModelFactory {
    private let moveItemService: MoveItemService
    private let statusNotifier: StatusNotifier
    private let eventDispatcher: EventDispatcher

    public init(
        moveItemService: MoveItemService,
        statusNotifier: StatusNotifier,
        eventDispatcher: EventDispatcher
    ) {
        self.moveItemService = moveItemService
        self.statusNotifier = statusNotifier
        self.eventDispatcher = eventDispatcher
    }

    public func create(for item: Item) -> MoveItemViewModel {
        .init(
            item: item,
            moveItemService: moveItemService,
            statusNotifier: statusNotifier,
            eventDispatcher: eventDispatcher
        )
    }
}
