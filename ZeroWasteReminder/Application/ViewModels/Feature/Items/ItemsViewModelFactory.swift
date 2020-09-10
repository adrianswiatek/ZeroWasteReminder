public final class ItemsViewModelFactory {
    private let itemsRepository: ItemsRepository
    private let statusNotifier: StatusNotifier
    private let itemsChangeListener: ItemsChangeListener
    private let eventDispatcher: EventDispatcher

    public init(
        itemsRepository: ItemsRepository,
        statusNotifier: StatusNotifier,
        itemsChangeListener: ItemsChangeListener,
        eventDispatcher: EventDispatcher
    ) {
        self.itemsRepository = itemsRepository
        self.statusNotifier = statusNotifier
        self.itemsChangeListener = itemsChangeListener
        self.eventDispatcher = eventDispatcher
    }

    public func create(for list: List) -> ItemsViewModel {
        .init(
            list: list,
            itemsRepository: itemsRepository,
            statusNotifier: statusNotifier,
            itemsChangeListener: itemsChangeListener,
            eventDispatcher: eventDispatcher
        )
    }
}
