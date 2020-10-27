import Combine
import Foundation

public final class SearchViewModel {
    public let searchBarViewModel: SearchBarViewModel

    public let requestSubject: PassthroughSubject<Request, Never>

    private let listsRepository: ListsRepository
    private let itemsRepository: ItemsReadRepository

    private var subscriptions: Set<AnyCancellable>
    private var cachedLists: [List]

    public init(listsRepository: ListsRepository, itemsRepository: ItemsReadRepository) {
        self.listsRepository = listsRepository
        self.itemsRepository = itemsRepository
        self.searchBarViewModel = SearchBarViewModel()

        self.requestSubject = .init()
        self.subscriptions = .init()
        self.cachedLists = []

        self.bind()
    }

    public func initializeLists() {
        listsRepository.fetchAll()
            .sink { [weak self] in self?.cachedLists = $0 }
            .store(in: &subscriptions)
    }

    private func bind() {
        searchBarViewModel.$searchTerm
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { print($0) }
            .store(in: &subscriptions)

        searchBarViewModel.dismissTap
            .sink { [weak self] in self?.requestSubject.send(.dismiss) }
            .store(in: &subscriptions)
    }
}

public extension SearchViewModel {
    enum Request {
        case dismiss
    }
}
