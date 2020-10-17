public final class ItemsViewModelFactory {
    private let itemsReadRepository: ItemsReadRepository
    private let itemsWriteRepository: ItemsWriteRepository
    private let statusNotifier: StatusNotifier
    private let updateListsDate: UpdateListsDate
    private let eventDispatcher: EventDispatcher

    public init(
        itemsReadRepository: ItemsReadRepository,
        itemsWriteRepository: ItemsWriteRepository,
        statusNotifier: StatusNotifier,
        updateListsDate: UpdateListsDate,
        eventDispatcher: EventDispatcher
    ) {
        self.itemsReadRepository = itemsReadRepository
        self.itemsWriteRepository = itemsWriteRepository
        self.statusNotifier = statusNotifier
        self.updateListsDate = updateListsDate
        self.eventDispatcher = eventDispatcher
    }

    public func create(for list: List) -> ItemsViewModel {
        .init(
            list: list,
            itemsReadRepository: itemsReadRepository,
            itemsWriteRepository: itemsWriteRepository,
            statusNotifier: statusNotifier,
            updateListsDate: updateListsDate,
            eventDispatcher: eventDispatcher
        )
    }
}
