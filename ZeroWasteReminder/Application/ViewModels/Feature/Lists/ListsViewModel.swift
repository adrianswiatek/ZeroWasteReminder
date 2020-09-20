import Combine
import Foundation

public final class ListsViewModel {
    @Published public private(set) var lists: [List]
    @Published public var isViewOnTop: Bool

    public var isLoading: AnyPublisher<Bool, Never> {
        isLoadingSubject.eraseToAnyPublisher()
    }

    public let canRemotelyConnect: AnyPublisher<Bool, Never>
    public let requestsSubject: PassthroughSubject<Request, Never>

    private let isLoadingSubject: CurrentValueSubject<Bool, Never>
    private let needsToFetchSubject: PassthroughSubject<Bool, Never>

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
        self.isViewOnTop = false

        self.isLoadingSubject = .init(false)
        self.needsToFetchSubject = .init()
        self.requestsSubject = .init()
        self.subscriptions = []

        self.bind()
    }

    public func fetchLists() {
        listsRepository.fetchAll()
            .sink { [weak self] in
                self?.lists = $0.sorted { $0.updateDate > $1.updateDate}
                self?.isLoadingSubject.send(false)
            }
            .store(in: &subscriptions)

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
        listsRepository.update(.just(list))
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

        Publishers.CombineLatest($isViewOnTop, needsToFetchSubject)
            .filter { $0.0 && $0.1 }
            .sink { [weak self] _ in
                self?.needsToFetchSubject.send(false)
                self?.fetchLists()
            }
            .store(in: &subscriptions)
    }

    private func handleEvent(_ event: AppEvent) {
        var updatedLists = lists

        switch event {
        case let event as ListAdded:
            updatedLists.insert(event.list, at: 0)
        case let event as ListRemoved:
            updatedLists.removeAll { $0.id == event.list.id }
        case let event as ListsUpdated:
            event.lists.forEach { list in
                updatedLists.firstIndex { $0.id == list.id }.map { updatedLists[$0] = list }
            }
        case let event as ErrorOccured:
            requestsSubject.send(.showErrorMessage(event.error.localizedDescription))
        case is ListRemotelyAdded:
            return fetchOrSchedule(delayInSeconds: 3)
        case is ListRemotelyRemoved, is ListRemotelyUpdated:
            return fetchOrSchedule()
        default:
            return
        }

        lists = sortedByUpdateDate(updatedLists)
    }

    private func sortedByUpdateDate(_ lists: [List]) -> [List] {
        lists.sorted { $0.updateDate > $1.updateDate }
    }

    private func fetchOrSchedule(delayInSeconds: Int = 0) {
        if isViewOnTop {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delayInSeconds)) {
                self.fetchLists()
            }
        } else {
            needsToFetchSubject.send(true)
        }
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
