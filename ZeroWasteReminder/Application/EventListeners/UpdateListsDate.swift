import Combine
import Foundation

public final class UpdateListsDate {
    private let listsRepository: ListsRepository
    private let eventDispatcher: EventDispatcher

    private var subscription: AnyCancellable?

    public init(
        _ listsRepository: ListsRepository,
        _ eventDispatcher: EventDispatcher
    ) {
        self.listsRepository = listsRepository
        self.eventDispatcher = eventDispatcher
    }

    public func listen(in list: List) {
        subscription = eventDispatcher.events
            .sink { [weak self] in self?.handleEvent($0, with: list) }
    }

    public func stopListening() {
        subscription = nil
    }

    private func handleEvent(_ event: AppEvent, with list: List) {
        switch event {
        case is ItemAdded, is ItemUpdated, is ItemsRemoved:
            update(list)
        case let event as ItemMoved:
            update(list, event.targetList)
        default:
            break
        }
    }

    private func update(_ lists: List...) {
        listsRepository.update(lists.map { $0.withUpdateDate(Date()) })
    }
}
