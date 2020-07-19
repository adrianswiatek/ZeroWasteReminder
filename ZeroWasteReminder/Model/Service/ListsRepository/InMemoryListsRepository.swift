import Combine
import Foundation

public final class InMemoryListsRepository: ListsRepository {
    public var events: AnyPublisher<ListsEvent, Never> {
        eventsSubject.eraseToAnyPublisher()
    }

    private let eventsSubject = PassthroughSubject<ListsEvent, Never>()
    private var lists = [List]()

    public func add(_ list: List) {
        lists.append(list)
        eventsSubject.send(.added(list))
    }

    public func fetchAll() {
        eventsSubject.send(.fetched(lists))
    }

    public func remove(_ list: List) {
        lists.removeAll { $0.id == list.id }
        eventsSubject.send(.removed(list))
    }

    public func update(_ list: List) {
        lists.firstIndex { $0.id == list.id }.map { lists[$0] = list }
        eventsSubject.send(.updated(list))
    }
}
