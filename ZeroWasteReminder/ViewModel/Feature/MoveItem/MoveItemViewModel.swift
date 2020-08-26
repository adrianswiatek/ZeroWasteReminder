import Combine

public final class MoveItemViewModel {
    @Published public var lists: [List]
    @Published private var selectedList: List?

    public var isLoading: AnyPublisher<Bool, Never>
    public let requestsSubject: PassthroughSubject<Request, Never>

    public var canMoveItem: AnyPublisher<Bool, Never> {
        $selectedList.map { $0 != nil }.eraseToAnyPublisher()
    }

    private let item: Item
    private let moveItemService: MoveItemServiceProtocol

    private var subscriptions: Set<AnyCancellable>

    public init(item: Item, moveItemService: MoveItemServiceProtocol) {
        self.item = item

        let moveItemService = MoveItemServiceStateDecorator(moveItemService)
        self.moveItemService = moveItemService
        self.isLoading = moveItemService.isLoading
        self.requestsSubject = .init()

        self.lists = []
        self.subscriptions = []

        self.bind()
    }

    public func fetchLists() {
        moveItemService.fetchLists(for: item)
    }

    public func selectList(_ list: List) {
        selectedList = list
    }

    public func moveItem() {
        selectedList.map { moveItemService.moveItem(item, toList: $0) }
    }

    private func bind() {
        moveItemService.events
            .sink { [weak self] in self?.handleEvent($0) }
            .store(in: &subscriptions)
    }

    private func handleEvent(_ event: MoveItemEvent) {
        switch event {
        case .error(let error):
            requestsSubject.send(.showErrorMessage(error.localizedDescription))
        case .fetched(let lists):
            self.lists = lists.sorted { $0.name < $1.name }
        case .moved:
            requestsSubject.send(.dismiss)
        }
    }
}

public extension MoveItemViewModel {
    enum Request: Equatable {
        case dismiss
        case showErrorMessage(_ message: String)
    }
}
