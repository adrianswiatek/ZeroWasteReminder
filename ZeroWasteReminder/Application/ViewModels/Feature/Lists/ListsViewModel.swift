import Combine
import Foundation

public final class ListsViewModel {
    @Published public private(set) var lists: [List]

    public var isLoading: AnyPublisher<Bool, Never> {
        isLoadingSubject.eraseToAnyPublisher()
    }

    public let canRemotelyConnect: AnyPublisher<Bool, Never>
    public let requestsSubject: PassthroughSubject<Request, Never>

    private let isLoadingSubject: CurrentValueSubject<Bool, Never>

    private let listsRepository: ListsRepository
    private let eventDispatcher: EventDispatcher
    private var subscriptions: Set<AnyCancellable>

    public init(
        listsRepository: ListsRepository,
        statusNotifier: StatusNotifier,
        eventDispatcher: EventDispatcher
    ) {
        self.listsRepository = listsRepository
        self.eventDispatcher = eventDispatcher

        self.canRemotelyConnect = statusNotifier.remoteStatus
            .map { $0 == .connected }
            .eraseToAnyPublisher()

        self.lists = []
        self.isLoadingSubject = .init(false)
        self.requestsSubject = .init()
        self.subscriptions = []

        self.bind()
    }

    public func fetchLists() {
        listsRepository.fetchAll()
        isLoadingSubject.send(true)
    }

    public func index(of list: List) -> Int? {
        lists.firstIndex(of: list)
    }

    public func addList(withName name: String) {
        let id = listsRepository.nextId()
        listsRepository.add(.init(id: id, name: name))

        isLoadingSubject.send(true)
    }

    public func updateList(_ list: List) {
        listsRepository.update(list)
        isLoadingSubject.send(true)
    }

    public func removeList(_ list: List) {
        listsRepository.remove(list)
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
        var updatedLists = lists

        switch event {
        case let event as ListAdded:
            updatedLists.insert(event.list, at: 0)
        case let event as ListsFetched:
            updatedLists = event.lists
        case let event as ListRemoved:
            updatedLists.removeAll { $0.id == event.list.id }
        case let event as ListsUpdated:
            event.lists.forEach { list in
                updatedLists.firstIndex { $0.id == list.id }.map { updatedLists[$0] = list }
            }
        case let event as ErrorOccured:
            requestsSubject.send(.showErrorMessage(event.error.localizedDescription))
        default:
            return
        }

        lists = updatedLists.sorted { $0.updateDate > $1.updateDate }
    }
}

public extension ListsViewModel {
    enum Request: Equatable {
        case changeName(_ list: List)
        case disableLoadingIndicatorOnce
        case discardChanges
        case openItems(_ list: List)
        case remove(_ list: List)
        case showErrorMessage(_ message: String)
    }
}
