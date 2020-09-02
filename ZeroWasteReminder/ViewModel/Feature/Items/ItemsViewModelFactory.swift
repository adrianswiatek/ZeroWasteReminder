public final class ItemsViewModelFactory {
    private let itemsRepository: ItemsRepository
    private let statusNotifier: StatusNotifier

    public init(itemsRepository: ItemsRepository, statusNotifier: StatusNotifier) {
        self.itemsRepository = itemsRepository
        self.statusNotifier = statusNotifier
    }

    public func create(for list: List) -> ItemsViewModel {
        .init(list: list, itemsRepository: itemsRepository, statusNotifier: statusNotifier)
    }
}
