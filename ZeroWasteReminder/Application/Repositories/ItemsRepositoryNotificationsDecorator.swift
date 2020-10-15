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
            self?.fetchAllCancellable = self?.itemsRepository.fetchAll(from: list)
                .flatMap { [weak self] in
                    self?.itemsWithAlertOption($0, in: list).eraseToAnyPublisher() ?? Empty().eraseToAnyPublisher()
                }
                .sink(
                    receiveCompletion: { [weak self] _ in self?.fetchAllCancellable?.cancel() },
                    receiveValue: { promise(.success($0)) }
                )
        }
    }

    public func fetch(by id: Id<Item>) -> Future<Item?, Never> {
        Future { [weak self] promise in
            self?.fetchCancellable = self?.itemsRepository.fetch(by: id)
                .flatMap { [weak self] in
                    self?.itemWithAlertOption($0).eraseToAnyPublisher() ?? Empty().eraseToAnyPublisher()
                }
                .sink(
                    receiveCompletion: { [weak self] _ in self?.fetchAllCancellable?.cancel() },
                    receiveValue: { promise(.success($0)) }
                )
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

    private func itemsWithAlertOption(_ items: [Item], in list: List) -> Future<[Item], Never> {
        Future { [weak self] promise in
            let notifications = self?.notificationRepository.fetchAll(from: list)
            let items =  items.reduce(into: [Item]()) { items, item in
                let notification = notifications?.first { $0.itemId == item.id }
                items += notification != nil ? [item.withAlertOption(notification!.alertOption)] : [item]
            }
            promise(.success(items))
        }
    }

    private func itemWithAlertOption(_ item: Item?) -> Future<Item?, Never> {
        Future { [weak self] promise in
            let item = item
                .flatMap { self?.notificationRepository.fetch(for: $0) }
                .flatMap { item?.withAlertOption($0.alertOption) }

            promise(.success(item))
        }
    }
}
