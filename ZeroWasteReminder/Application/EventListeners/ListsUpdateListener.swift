import Combine
import Foundation

public final class ListsChangeListener {
    private let listsRepository: ListsRepository
    private let eventDispatcher: EventDispatcher

    private var subscriptions: Set<AnyCancellable>

    public init(_ listsRepository: ListsRepository, _ eventDispatcher: EventDispatcher) {
        self.listsRepository = listsRepository
        self.eventDispatcher = eventDispatcher
        self.subscriptions = []
    }

    public func startListening() {
        eventDispatcher.events
            .sink { [weak self] in self?.handleEvent($0) }
            .store(in: &subscriptions)
    }

    private func handleEvent(_ event: AppEvent) {
        switch event {
        case is ListRemotelyAdded:
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
                self.listsRepository.fetchAll()
            }
        case is ListRemotelyRemoved, is ListRemotelyUpdated:
            listsRepository.fetchAll()
        default:
            break
        }
    }
}
