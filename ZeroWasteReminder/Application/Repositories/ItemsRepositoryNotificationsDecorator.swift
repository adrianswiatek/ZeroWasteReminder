import Combine

public final class ItemsRepositoryNotificationsDecorator: ItemsRepository {
    private let itemsRepository: ItemsRepository
    private let notificationRepository: ItemNotificationsRepository

    private var fetchAllCancellable: AnyCancellable?
    private var fetchCancellable: AnyCancellable?

    public init(itemsRepository: ItemsRepository, notificationsRepository: ItemNotificationsRepository) {
        self.itemsRepository = itemsRepository
        self.notificationRepository = notificationsRepository
    }

    public func fetchAll(from list: List) -> Future<[Item], Never> {
        Future { [weak self] promise in
            self?.fetchAllCancellable = self?.itemsRepository.fetchAll(from: list).sink {
                promise(.success(self?.itemsWithAlertOption($0, in: list) ?? []))
                self?.fetchAllCancellable?.cancel()
            }
        }
    }

    public func fetch(by id: Id<Item>) -> Future<Item?, Never> {
        Future { [weak self] promise in
            self?.fetchCancellable = self?.itemsRepository.fetch(by: id).sink {
                promise(.success(self?.itemWithAlertOption($0)))
                self?.fetchCancellable?.cancel()
            }
        }
    }

    public func add(_ itemToSave: ItemToSave) {
        itemsRepository.add(itemToSave)
    }

    public func update(_ item: Item) {
        itemsRepository.update(item)
    }

    public func move(_ item: Item, to list: List) {
        itemsRepository.move(item, to: list)
    }

    public func remove(_ item: Item) {
        itemsRepository.remove(item)
    }

    public func remove(_ items: [Item]) {
        itemsRepository.remove(items)
    }

    private func itemWithAlertOption(_ item: Item?) -> Item? {
        item.flatMap { notificationRepository.fetch(for: $0) }
            .flatMap { item?.withAlertOption($0.alertOption) }
    }

    private func itemsWithAlertOption(_ items: [Item], in list: List) -> [Item] {
        let notifications = notificationRepository.fetchAll(from: list)
        return items.reduce(into: [Item]()) { items, item in
            let notification = notifications.first { $0.itemId == item.id }
            items += notification != nil ? [item.withAlertOption(notification!.alertOption)] : [item]
        }
    }
}
