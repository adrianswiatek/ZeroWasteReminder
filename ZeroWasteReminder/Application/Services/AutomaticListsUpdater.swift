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
            .sink { [weak self] in
                let lists = $0.map { $0.withDate(Date()) }
                self?.listsRepository.update(lists)
            }
            .store(in: &subscriptions)
    }
}
