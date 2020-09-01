import Combine

public final class DefaultListsChangeListener: ListsChangeListener {
    private let itemsRepository: ItemsRepository
    private let moveItemService: MoveItemServiceProtocol

    private var listsIds: [Id<List>]
    private var subscriptions: Set<AnyCancellable>

    public init(itemsRepository: ItemsRepository, moveItemService: MoveItemServiceProtocol) {
        self.itemsRepository = itemsRepository
        self.moveItemService = moveItemService

        self.listsIds = []
        self.subscriptions = []
    }

    public func releaseChangedListIds() -> [Id<List>] {
        defer { listsIds.removeAll() }
        return listsIds
    }

    public func startListening(in list: List) {
        itemsRepository.events
            .sink { [weak self] in self?.updateChangedListsIfNeeded(list, basedOn: $0) }
            .store(in: &subscriptions)

        moveItemService.events
            .sink { [weak self] in self?.updateChangedListsIfNeeded(basedOn: $0) }
            .store(in: &subscriptions)
    }

    public func stopListening() {
        subscriptions = []
    }

    private func updateChangedListsIfNeeded(_ list: List, basedOn event: ItemsEvent) {
        switch event {
        case .added, .updated, .removed:
            setAsChanged(list.id)
        case .error, .fetched, .noResult:
            break
        }
    }

    private func updateChangedListsIfNeeded(basedOn event: MoveItemEvent) {
        switch event {
        case .moved(_, let list):
            setAsChanged(list.id)
        case .error, .fetched:
            break
        }
    }

    private func setAsChanged(_ listId: Id<List>) {
        guard !listsIds.contains(listId) else {
            return
        }
        listsIds.append(listId)
    }
}
