public final class ItemsViewModelFactory {
    private let itemsRepository: ItemsRepository
    private let statusNotifier: StatusNotifier
    private let eventBus: EventBus

    public init(
        itemsRepository: ItemsRepository,
        statusNotifier: StatusNotifier,
        eventBus: EventBus
    ) {
        self.itemsRepository = itemsRepository
        self.statusNotifier = statusNotifier
        self.eventBus = eventBus
    }

    public func create(for list: List) -> ItemsViewModel {
        .init(
            list: list,
            itemsRepository: itemsRepository,
            statusNotifier: statusNotifier,
            eventBus: eventBus
        )
    }
}
