import Combine

public final class MoveItemViewModel {
    @Published public var lists: [List]

    public let requestSubject: PassthroughSubject<Request, Never>

    public var canMoveItem: AnyPublisher<Bool, Never> {
        Just(false).share().eraseToAnyPublisher()
    }

    private let item: Item
    private let moveItemService: MoveItemService

    private var subscriptions: Set<AnyCancellable>

    public init(item: Item, moveItemService: MoveItemService) {
        self.item = item
        self.moveItemService = moveItemService

        self.lists = []
        self.requestSubject = .init()
        self.subscriptions = []

        self.bind()
        self.moveItemService.fetchLists(for: item)
    }

    private func bind() {
        moveItemService.events
            .sink { [weak self] in self?.handleEvent($0) }
            .store(in: &subscriptions)
    }

    private func handleEvent(_ event: MoveItemEvent) {
        switch event {
        case .fetched(let lists):
            self.lists = lists
        case .moved:
            requestSubject.send(.dismiss)
        }

        print(event)
    }
}


public extension MoveItemViewModel {
    enum Request: Equatable {
        case dismiss
    }
}
