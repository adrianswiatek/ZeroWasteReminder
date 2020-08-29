import Combine
import Foundation

public final class ListsViewModel {
    @Published public private(set) var lists: [List]

    public let isLoading: AnyPublisher<Bool, Never>
    public let canRemotelyConnect: AnyPublisher<Bool, Never>
    public let requestsSubject: PassthroughSubject<Request, Never>

    private let listsRepository: ListsRepository
    private let listsChangeListener: ListsChangeListener
    private var subscriptions: Set<AnyCancellable>

    public init(
        listsRepository: ListsRepository,
        listsChangeListener: ListsChangeListener,
        statusNotifier: StatusNotifier
    ) {
        let listsRepositoryDecorator = ListsRepositoryStateDecorator(listsRepository)
        self.listsRepository = listsRepositoryDecorator
        self.isLoading = listsRepositoryDecorator.isLoading

        self.listsChangeListener = listsChangeListener
        self.canRemotelyConnect = statusNotifier.remoteStatus.map { $0 == .connected }.eraseToAnyPublisher()

        self.lists = []
        self.requestsSubject = .init()
        self.subscriptions = []

        self.bind()
    }

    public func fetchLists() {
        listsRepository.fetchAll()
    }

    public func refreshListsIfNeeded() {
        listsChangeListener.stopListening()

        let changedListIds = listsChangeListener.releaseChangedListIds()
        guard !changedListIds.isEmpty else { return }

        let updatedLists = lists
            .filter { changedListIds.contains($0.id) }
            .map { $0.withDate(Date()) }

        listsRepository.update(updatedLists)
    }

    public func index(of list: List) -> Int? {
        lists.firstIndex(of: list)
    }

    public func addList(withName name: String) {
        let id = listsRepository.nextId()
        listsRepository.add(.init(id: id, name: name))
    }

    public func updateList(_ list: List) {
        listsRepository.update(list)
    }

    public func removeList(_ list: List) {
        listsRepository.remove(list)
    }

    private func bind() {
        listsRepository.events
            .sink { [weak self] in self?.updateListsWithEvent($0) }
            .store(in: &subscriptions)

        requestsSubject
            .compactMap {
                guard case .openItems(let list) = $0 else { return nil }
                return list
            }
            .sink { [weak self] in self?.listsChangeListener.startListening(in: $0) }
            .store(in: &subscriptions)
    }

    private func updateListsWithEvent(_ event: ListsEvent) {
        var updatedLists = lists

        switch event {
        case .added(let list):
            updatedLists.insert(list, at: 0)
        case .fetched(let fetchedLists):
            updatedLists = fetchedLists
        case .removed(let list):
            updatedLists.removeAll { $0.id == list.id }
        case .updated(let lists):
            lists.forEach { list in
                updatedLists.firstIndex { $0.id == list.id }.map { updatedLists[$0] = list }
            }
        case .error(let error):
            requestsSubject.send(.showErrorMessage(error.localizedDescription))
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
