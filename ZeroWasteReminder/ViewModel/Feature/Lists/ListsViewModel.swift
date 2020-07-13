import Combine

public final class ListsViewModel {
    public var lists: AnyPublisher<[String], Never> {
        listsSubject.eraseToAnyPublisher()
    }

    public var needsOpenList: AnyPublisher<Void, Never> {
        needsOpenListSubject.eraseToAnyPublisher()
    }

    private let listsSubject: CurrentValueSubject<[String], Never>
    private let needsOpenListSubject: PassthroughSubject<Void, Never>

    public init() {
        listsSubject = .init([])
        needsOpenListSubject = .init()

        listsSubject.value = [
            "Pantry",
            "Cosmetics",
            "Alcohol",
            "Sweets",
            "Fridgerator",
            "Basement"
        ]
    }

    public func addList(_ list: String) {
        listsSubject.value.insert(list, at: 0)
    }

    public func setNeedsOpenList() {
        needsOpenListSubject.send()
    }
}
