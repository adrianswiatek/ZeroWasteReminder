import Combine
import Foundation

public final class InMemoryListsRepository: ListsRepository {
    private let listsSubject = CurrentValueSubject<[List], Never>([])
    public var lists: AnyPublisher<[List], Never> {
        listsSubject.eraseToAnyPublisher()
    }

    public func add(_ list: List) -> Future<Void, ServiceError> {
        listsSubject.value.insert(list, at: 0)
        return Future { $0(.success(())) }
    }

    public func refresh() -> Future<Void, ServiceError> {
        Future { $0(.success(())) }
    }

    public func update(_ list: List) -> Future<Void, ServiceError> {
        listsSubject.value
            .firstIndex { $0.id == list.id }
            .map { listsSubject.value[$0] = list }

        return Future { $0(.success(())) }
    }

    public func remove(_ list: List) -> Future<Void, ServiceError> {
        listsSubject.value.removeAll { $0.id == list.id }
        return Future { $0(.success(())) }
    }
}
