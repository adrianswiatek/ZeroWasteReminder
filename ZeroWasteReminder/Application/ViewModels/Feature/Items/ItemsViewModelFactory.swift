public final class ItemsViewModelFactory {
    private let itemsRepository: ItemsRepository
    private let listItemsChangeListener: ListItemsChangeListener
    private let statusNotifier: StatusNotifier

    public init(
        itemsRepository: ItemsRepository,
        listItemsChangeListener: ListItemsChangeListener,
        statusNotifier: StatusNotifier
    ) {
        self.itemsRepository = itemsRepository
        self.listItemsChangeListener = listItemsChangeListener
        self.statusNotifier = statusNotifier
    }

    public func create(for list: List) -> ItemsViewModel {
        .init(
            list: list,
            itemsRepository: itemsRepository,
            listItemsChangeListener: listItemsChangeListener,
            statusNotifier: statusNotifier
        )
    }
}
