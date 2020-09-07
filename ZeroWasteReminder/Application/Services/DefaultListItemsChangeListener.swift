import Combine
import Foundation

public final class DefaultListItemsChangeListener: ListItemsChangeListener {
    public var updatedItemInList: AnyPublisher<List, Never> {
        updatedItemInListSubject.eraseToAnyPublisher()
    }

    private let itemsRepository: ItemsRepository
    private let moveItemService: MoveItemService

    private let updatedItemInListSubject: PassthroughSubject<List, Never>
    private var subscriptions: Set<AnyCancellable>

    public init(itemsRepository: ItemsRepository, moveItemService: MoveItemService) {
        self.itemsRepository = itemsRepository
        self.moveItemService = moveItemService

        self.updatedItemInListSubject = .init()
        self.subscriptions = []
    }

    public func startListeningForItemChange(in list: List) {
        itemsRepository.events
            .sink { [weak self] in self?.updateListIfNeeded(list, basedOn: $0) }
            .store(in: &subscriptions)

        moveItemService.events
            .sink { [weak self] in self?.updateListIfNeeded(basedOn: $0) }
            .store(in: &subscriptions)
    }

    public func stopListening() {
        subscriptions = []
    }

    private func updateListIfNeeded(_ list: List, basedOn event: ItemsEvent) {
        switch event {
        case .added, .updated, .removed:
            updatedItemInListSubject.send(list)
        case .error, .fetched, .noResult:
            break
        }
    }

    private func updateListIfNeeded(basedOn event: MoveItemEvent) {
        switch event {
        case .moved(_, let list):
            updatedItemInListSubject.send(list)
        case .error, .fetched:
            break
        }
    }
}
