public final class ItemsViewModelFactory {
    private let itemsRepository: ItemsRepository
    private let statusNotifier: StatusNotifier
    private let updateListsDate: UpdateListsDate
    private let eventDispatcher: EventDispatcher

    public init(
        itemsRepository: ItemsRepository,
        statusNotifier: StatusNotifier,
        updateListsDate: UpdateListsDate,
        eventDispatcher: EventDispatcher
    ) {
        self.itemsRepository = itemsRepository
        self.statusNotifier = statusNotifier
        self.updateListsDate = updateListsDate
        self.eventDispatcher = eventDispatcher
    }

    public func create(for list: List) -> ItemsViewModel {
        .init(
            list: list,
            itemsRepository: itemsRepository,
            statusNotifier: statusNotifier,
            updateListsDate: updateListsDate,
            eventDispatcher: eventDispatcher
        )
    }
}
