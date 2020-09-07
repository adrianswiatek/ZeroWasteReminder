public final class ItemsViewModelFactory {
    private let itemsRepository: ItemsRepository
    private let listItemsChangeListener: ListItemsChangeListener
    private let statusNotifier: StatusNotifier
    private let eventBus: EventBus

    public init(
        itemsRepository: ItemsRepository,
        listItemsChangeListener: ListItemsChangeListener,
        statusNotifier: StatusNotifier,
        eventBus: EventBus
    ) {
        self.itemsRepository = itemsRepository
        self.listItemsChangeListener = listItemsChangeListener
        self.statusNotifier = statusNotifier
        self.eventBus = eventBus
    }

    public func create(for list: List) -> ItemsViewModel {
        .init(
            list: list,
            itemsRepository: itemsRepository,
            listItemsChangeListener: listItemsChangeListener,
            statusNotifier: statusNotifier,
            eventBus: eventBus
        )
    }
}
