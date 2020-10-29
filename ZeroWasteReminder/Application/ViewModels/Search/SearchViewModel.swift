import Combine
import Foundation

public final class SearchViewModel {
    @Published public var items: [SearchItem]
    public let searchBarViewModel: SearchBarViewModel

    public let requestsSubject: PassthroughSubject<Request, Never>

    private let listsRepository: ListsRepository
    private let itemsRepository: ItemsReadRepository
    private let eventDispatcher: EventDispatcher

    private var cachedLists: [List]

    private let searchTriggerSubject: PassthroughSubject<Void, Never>
    private var subscriptions: Set<AnyCancellable>
    private var fetchListsSubscription: AnyCancellable?
    private var searchSubscription: AnyCancellable?

    public init(
        listsRepository: ListsRepository,
        itemsRepository: ItemsReadRepository,
        eventDispatcher: EventDispatcher
    ) {
        self.listsRepository = listsRepository
        self.itemsRepository = itemsRepository
        self.eventDispatcher = eventDispatcher

        self.items = []
        self.searchBarViewModel = SearchBarViewModel()

        self.requestsSubject = .init()
        self.searchTriggerSubject = .init()
        self.subscriptions = .init()
        self.cachedLists = []

        self.bind()
    }

    public func initialize() {
        fetchListsSubscription = listsRepository.fetchAll()
            .sink(
                receiveCompletion: { [weak self] _ in self?.fetchListsSubscription?.cancel() },
                receiveValue: { [weak self] in self?.cachedLists = $0 }
            )
    }

    public func cleanUp() {
        items = []
    }

    public func item(atIndex index: Int) -> Item {
        precondition(0 ..< items.count ~= index, "Invalid index.")
        return items[index].item
    }

    private func bind() {
        searchBarViewModel.$searchTerm
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .sink { [weak self] in self?.search(by: $0) }
            .store(in: &subscriptions)

        searchBarViewModel.dismissTap
            .sink { [weak self] in self?.requestsSubject.send(.dismiss) }
            .store(in: &subscriptions)

        eventDispatcher.events
            .compactMap { [weak self] in self?.updatedWithEvent($0) }
            .filter { [weak self] in $0 != self?.items }
            .delay(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .sink { [weak self] in self?.items = $0 }
            .store(in: &subscriptions)
    }

    private func updatedWithEvent(_ event: AppEvent) -> [SearchItem] {
        var updatedItems = items

        switch event {
        case let event as ItemsRemoved:
            event.items.forEach { item in
                updatedItems.removeAll { item.id == $0.item.id }
            }
        case let event as ItemUpdated:
            updatedItems.firstIndex { $0.item.id == event.item.id }.map {
                updatedItems[$0] = updatedItems[$0].withItem(event.item)
            }
        case let event as ItemMoved:
            updatedItems = updatedItems.removedAll { $0.item.id == event.item.id }
        case let event as ErrorOccured:
            requestsSubject.send(.showErrorMessage(event.error.localizedDescription))
        default:
            return items
        }

        return updatedItems
    }

    private func search(by searchTerm: String) {
        searchSubscription = itemsRepository.fetch(by: searchTerm)
            .sink(
                receiveCompletion: { [weak self] _ in self?.searchSubscription?.cancel() },
                receiveValue: { [weak self] in self?.setSearchItems(with: $0) }
            )
    }

    private func setSearchItems(with items: [Item]) {
        self.items = items
            .reduce(into: [SearchItem]()) { searchItems, item in
                searchItems += .just(SearchItem(item: item, list: cachedLists.first { $0.id == item.listId }))
            }
            .sorted { $0.item.name < $1.item.name }
    }
}

public extension SearchViewModel {
    enum Request {
        case dismiss
        case showErrorMessage(_ message: String)
    }
}
