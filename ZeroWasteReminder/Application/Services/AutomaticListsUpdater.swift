import Combine
import Foundation

public final class AutomaticListUpdater {
    private let listsRepository: ListsRepository
    private let listItemsChangeListener: ListItemsChangeListener

    private var subscriptions: Set<AnyCancellable>

    public init(
        _ listsRepository: ListsRepository,
        _ listItemsChangeListener: ListItemsChangeListener
    ) {
        self.listsRepository = listsRepository
        self.listItemsChangeListener = listItemsChangeListener
        self.subscriptions = []
    }

    public func startUpdating() {
        listItemsChangeListener.updatedItemInList
            .sink { [weak self] in self?.listsRepository.update($0.withDate(.init())) }
            .store(in: &subscriptions)
    }
}
