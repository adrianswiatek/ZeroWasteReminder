import Combine
import Foundation

public final class DefaultListItemsUpdateListener: ListItemsUpdateListener {
    public var updatedItemInLists: AnyPublisher<[List], Never> {
        updatedItemInListsSubject.eraseToAnyPublisher()
    }

    private let listsRepository: ListsRepository
    private let itemsRepository: ItemsRepository
    private let moveItemService: MoveItemService

    private let updatedItemInListsSubject: PassthroughSubject<[List], Never>
    private var subscriptions: Set<AnyCancellable>

    public init(
        listsRepository: ListsRepository,
        itemsRepository: ItemsRepository,
        moveItemService: MoveItemService
    ) {
        self.listsRepository = listsRepository
        self.itemsRepository = itemsRepository
        self.moveItemService = moveItemService

        self.updatedItemInListsSubject = .init()
        self.subscriptions = []
    }

    public func startListening(in list: List) {
        itemsRepository.events
            .sink { [weak self] in self?.updateListIfNeeded(list, basedOn: $0) }
            .store(in: &subscriptions)

        moveItemService.events
            .sink { [weak self] in self?.updateListIfNeeded(list, basedOn: $0) }
            .store(in: &subscriptions)
    }

    public func stopListening() {
        subscriptions = []
    }

    private func updateListIfNeeded(_ list: List, basedOn event: ItemsEvent) {
        switch event {
        case .added, .updated, .removed:
            updatedItemInListsSubject.send([list])
        case .error, .fetched, .noResult:
            break
        }
    }

    private func updateListIfNeeded(_ list: List, basedOn event: MoveItemEvent) {
        switch event {
        case .moved(_, let targetList):
            updatedItemInListsSubject.send([list, targetList])
        case .error, .fetched:
            break
        }
    }
}
