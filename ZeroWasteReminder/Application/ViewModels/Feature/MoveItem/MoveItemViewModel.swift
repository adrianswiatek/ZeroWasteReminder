import Combine

public final class MoveItemViewModel {
    @Published public var lists: [List]
    @Published private var selectedList: List?

    public let itemName: String

    public let requestsSubject: PassthroughSubject<Request, Never>

    public var isLoading: AnyPublisher<Bool, Never> {
        isLoadingSubject.eraseToAnyPublisher()
    }

    public var canMoveItem: AnyPublisher<Bool, Never> {
        $selectedList.map { $0 != nil }.eraseToAnyPublisher()
    }

    private let isLoadingSubject: CurrentValueSubject<Bool, Never>

    private let item: Item
    private let moveItemService: MoveItemService
    private let eventDispatcher: EventDispatcher

    private var subscriptions: Set<AnyCancellable>

    public init(item: Item, moveItemService: MoveItemService, eventDispatcher: EventDispatcher) {
        self.item = item
        self.moveItemService = moveItemService
        self.eventDispatcher = eventDispatcher

        self.requestsSubject = .init()
        self.isLoadingSubject = .init(false)

        self.itemName = item.name
        self.lists = []
        self.subscriptions = []

        self.bind()
    }

    public func fetchLists() {
        moveItemService.fetchLists(for: item)
        isLoadingSubject.send(true)
    }

    public func selectList(_ list: List) {
        selectedList = list
    }

    public func moveItem() {
        guard let selectedList = selectedList else { return }

        moveItemService.moveItem(item, to: selectedList)
        isLoadingSubject.send(true)
    }

    private func bind() {
        eventDispatcher.events
            .sink { [weak self] in
                self?.handleEvent($0)
                self?.isLoadingSubject.send(false)
            }
            .store(in: &subscriptions)
    }

    private func handleEvent(_ event: AppEvent) {
        switch event {
        case is ItemMoved:
            requestsSubject.send(.dismiss)
        case let event as ListsFetchedForItemToMove:
            lists = event.lists.sorted { $0.name < $1.name }
        case let event as ErrorOccured:
            requestsSubject.send(.showErrorMessage(event.error.localizedDescription))
        default:
            break
        }
    }
}

public extension MoveItemViewModel {
    enum Request: Equatable {
        case disableLoadingIndicatorOnce
        case dismiss
        case showErrorMessage(_ message: String)
    }
}
