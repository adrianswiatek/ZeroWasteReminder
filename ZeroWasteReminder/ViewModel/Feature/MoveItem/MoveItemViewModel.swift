import Combine

public final class MoveItemViewModel {
    @Published public var lists: [List]
    @Published private var selectedList: List?

    public let requestsSubject: PassthroughSubject<Request, Never>

    public var isLoading: AnyPublisher<Bool, Never> {
        isLoadingSubject.eraseToAnyPublisher()
    }

    public var canMoveItem: AnyPublisher<Bool, Never> {
        $selectedList.map { $0 != nil }.eraseToAnyPublisher()
    }

    private let item: Item
    private let moveItemService: MoveItemService
    private let isLoadingSubject: PassthroughSubject<Bool, Never>

    private var subscriptions: Set<AnyCancellable>

    public init(item: Item, moveItemService: MoveItemService) {
        self.item = item
        self.moveItemService = moveItemService

        self.lists = []
        self.subscriptions = []

        self.requestsSubject = .init()
        self.isLoadingSubject = .init()

        self.bind()
        self.fetchLists()
    }

    public func fetchLists() {
        moveItemService.fetchLists(for: item)
        isLoadingSubject.send(true)
    }

    public func selectList(_ list: List) {
        selectedList = list
    }

    public func moveItem() {
        selectedList.map { moveItemService.moveItem(item, toList: $0) }
        isLoadingSubject.send(true)
    }

    private func bind() {
        moveItemService.events
            .sink { [weak self] in
                self?.isLoadingSubject.send(false)
                self?.handleEvent($0)
            }
            .store(in: &subscriptions)
    }

    private func handleEvent(_ event: MoveItemEvent) {
        switch event {
        case .error(let error):
            requestsSubject.send(.showErrorMessage(error.localizedDescription))
        case .fetched(let lists):
            self.lists = lists.sorted { $0.updateDate > $1.updateDate }
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
