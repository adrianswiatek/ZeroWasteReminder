import Combine
import Foundation

public final class SearchViewModel {
    @Published public var items: [Item]

    public let searchBarViewModel: SearchBarViewModel

    public let requestSubject: PassthroughSubject<Request, Never>

    private let listsRepository: ListsRepository
    private let itemsRepository: ItemsReadRepository

    private var cachedLists: [List]

    private var subscriptions: Set<AnyCancellable>
    private var searchSubscription: AnyCancellable?

    public init(listsRepository: ListsRepository, itemsRepository: ItemsReadRepository) {
        self.listsRepository = listsRepository
        self.itemsRepository = itemsRepository
        self.searchBarViewModel = SearchBarViewModel()

        self.items = []

        self.requestSubject = .init()
        self.subscriptions = .init()
        self.cachedLists = []

        self.bind()
    }

    public func initialize() {
        listsRepository.fetchAll()
            .sink { [weak self] in self?.cachedLists = $0; print("1") }
            .store(in: &subscriptions)
    }

    public func cleanUp() {
        items = []
    }

    private func bind() {
        searchBarViewModel.$searchTerm
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] in self?.search(by: $0) }
            .store(in: &subscriptions)

        searchBarViewModel.dismissTap
            .sink { [weak self] in self?.requestSubject.send(.dismiss) }
            .store(in: &subscriptions)
    }

    private func search(by searchTerm: String) {
        searchSubscription = itemsRepository.fetch(by: searchTerm)
            .sink(
                receiveCompletion: { [weak self] _ in self?.searchSubscription?.cancel() },
                receiveValue: { [weak self] in self?.items = $0 }
            )
    }
}

public extension SearchViewModel {
    enum Request {
        case dismiss
    }
}
