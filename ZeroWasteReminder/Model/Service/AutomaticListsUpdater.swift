import Combine
import Foundation

public final class AutomaticListsUpdater {
    // Retain information about which lists has been updated
    // Update list(s) only when user open lists page
    // Remember to make batch update

    private let listsRepository: ListsRepository
    private let itemsRepository: ItemsRepository
    private let moveItemService: MoveItemServiceProtocol

    private var subscriptions: Set<AnyCancellable>

    public init(
        listsRepository: ListsRepository,
        itemsRepository: ItemsRepository,
        moveItemService: MoveItemServiceProtocol
    ) {
        self.listsRepository = listsRepository
        self.itemsRepository = itemsRepository
        self.moveItemService = moveItemService

        self.subscriptions = []
    }

    deinit {
        print("AutomaticListsUpdater has been deinitialized.")
    }

    public func startUpdating(_ list: List) {
        itemsRepository.events
            .sink { [weak self] in self?.updateListIfNeeded(list, basedOn: $0) }
            .store(in: &subscriptions)

        moveItemService.events
            .sink { [weak self] in self?.updateListIfNeeded(basedOn: $0) }
            .store(in: &subscriptions)
    }

    private func updateListIfNeeded(_ list: List, basedOn event: ItemsEvent) {
        switch event {
        case .added, .updated, .removed: update(list)
        case .error, .fetched: break
        }
    }

    private func updateListIfNeeded(basedOn event: MoveItemEvent) {
        guard case let .moved(_, list) = event else { return }
        update(list)
    }

    private func update(_ list: List) {
        listsRepository.update(list.withDate(Date()))
    }
}
