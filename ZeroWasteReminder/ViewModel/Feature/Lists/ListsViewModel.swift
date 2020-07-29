import Combine

public final class ListsViewModel {
    @Published public private(set) var lists: [List]

    public let requestsSubject: PassthroughSubject<Request, Never>

    private let listsRepository: ListsRepository
    private var subscriptions: Set<AnyCancellable>

    public init(listsRepository: ListsRepository) {
        self.listsRepository = listsRepository

        self.lists = []
        self.requestsSubject = .init()
        self.subscriptions = []

        self.bind()
    }

    public func fetchLists() {
        listsRepository.fetchAll()
    }

    public func index(of list: List) -> Int? {
        lists.firstIndex(of: list)
    }

    public func list(at index: Int) -> List {
        guard (0 ..< lists.count) ~= index else {
            preconditionFailure("Index out of bounds.")
        }
        return lists[index]
    }

    public func addList(withName name: String) {
        listsRepository.add(.init(name: name))
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
        case .updated(let list):
            updatedLists.firstIndex { $0.id == list.id }.map { updatedLists[$0] = list }
        }

        lists = updatedLists.sorted { $0.updateDate > $1.updateDate }
    }
}

public extension ListsViewModel {
    enum Request: Equatable {
        case changeName(_ list: List)
        case discardChanges
        case openItems(_ list: List)
        case remove(_ list: List)
    }
}
