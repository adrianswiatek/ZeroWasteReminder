import Combine

public final class MoveItemServiceStateDecorator: MoveItemServiceProtocol {
    public var events: AnyPublisher<MoveItemEvent, Never> {
        moveItemService.events
    }

    public var isLoading: AnyPublisher<Bool, Never> {
        isLoadingSubject.eraseToAnyPublisher()
    }

    private let moveItemService: MoveItemServiceProtocol
    private let isLoadingSubject: PassthroughSubject<Bool, Never>
    private var subscriptions: Set<AnyCancellable>

    public init(_ moveItemService: MoveItemServiceProtocol) {
        self.moveItemService = moveItemService
        self.isLoadingSubject = .init()
        self.subscriptions = []
        self.bind()
    }

    public func fetchLists(for item: Item) {
        isLoadingSubject.send(true)
        moveItemService.fetchLists(for: item)
    }

    public func moveItem(_ item: Item, toList list: List) {
        isLoadingSubject.send(true)
        moveItemService.moveItem(item, toList: list)
    }

    private func bind() {
        events
            .sink { [weak self] _ in self?.isLoadingSubject.send(false) }
            .store(in: &subscriptions)
    }
}
