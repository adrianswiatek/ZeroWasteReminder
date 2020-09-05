import Combine

public final class ListsRepositoryStateDecorator: ListsRepository {
    public let events: AnyPublisher<ListsEvent, Never>

    public var isLoading: AnyPublisher<Bool, Never> {
        isLoadingSubject.eraseToAnyPublisher()
    }

    private let listsRepository: ListsRepository
    private let isLoadingSubject: PassthroughSubject<Bool, Never>
    private var subscriptions: Set<AnyCancellable>

    public init(_ listsRepository: ListsRepository) {
        self.listsRepository = listsRepository
        self.events = listsRepository.events
        self.isLoadingSubject = .init()
        self.subscriptions = []
        self.bind()
    }

    public func fetchAll() {
        isLoadingSubject.send(true)
        listsRepository.fetchAll()
    }

    public func add(_ list: List) {
        isLoadingSubject.send(true)
        listsRepository.add(list)
    }

    public func update(_ list: List) {
        isLoadingSubject.send(true)
        listsRepository.update(list)
    }

    public func update(_ lists: [List]) {
        isLoadingSubject.send(true)
        listsRepository.update(lists)
    }

    public func remove(_ list: List) {
        isLoadingSubject.send(true)
        listsRepository.remove(list)
    }

    private func bind() {
        events
            .sink { [weak self] _ in self?.isLoadingSubject.send(false) }
            .store(in: &subscriptions)
    }
}
