import Combine

public final class ItemsRepositoryStateDecorator: ItemsRepository {
    public var events: AnyPublisher<ItemsEvent, Never>

    public var isLoading: AnyPublisher<Bool, Never> {
        isLoadingSubject.eraseToAnyPublisher()
    }

    private let itemsRepository: ItemsRepository
    private let isLoadingSubject: PassthroughSubject<Bool, Never>
    private var subscriptions: Set<AnyCancellable>

    public init(_ itemsRepository: ItemsRepository) {
        self.itemsRepository = itemsRepository
        self.events = itemsRepository.events
        self.isLoadingSubject = .init()
        self.subscriptions = []
        self.bind()
    }

    public func fetch(by itemId: Id<Item>) {

    }

    public func fetchAll(from list: List) {
        isLoadingSubject.send(true)
        itemsRepository.fetchAll(from: list)
    }

    public func add(_ itemToSave: ItemToSave) {
        isLoadingSubject.send(true)
        itemsRepository.add(itemToSave)
    }

    public func update(_ item: Item) {
        isLoadingSubject.send(true)
        itemsRepository.update(item)
    }

    public func remove(_ item: Item) {
        isLoadingSubject.send(true)
        itemsRepository.remove(item)
    }

    public func remove(_ items: [Item]) {
        isLoadingSubject.send(true)
        itemsRepository.remove(items)
    }

    private func bind() {
        events
            .sink { [weak self] _ in self?.isLoadingSubject.send(false) }
            .store(in: &subscriptions)
    }
}
