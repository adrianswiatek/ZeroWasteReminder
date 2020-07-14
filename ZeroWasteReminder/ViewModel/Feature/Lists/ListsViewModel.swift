import Combine

public final class ListsViewModel {
    public var lists: AnyPublisher<[List], Never> {
        listsSubject.eraseToAnyPublisher()
    }

    public var needsOpenList: AnyPublisher<Void, Never> {
        needsOpenListSubject.eraseToAnyPublisher()
    }

    private let listsSubject: CurrentValueSubject<[List], Never>
    private let needsOpenListSubject: PassthroughSubject<Void, Never>

    public init() {
        listsSubject = .init([])
        needsOpenListSubject = .init()

        listsSubject.value = [
            .init(name: "Pantry"),
            .init(name: "Cosmetics"),
            .init(name: "Alcohol"),
            .init(name: "Sweets"),
            .init(name: "Fridgerator"),
            .init(name: "Basement")
        ]
    }

    public func addList(withName name: String) {
        listsSubject.value.insert(.init(name: name), at: 0)
    }

    public func removeList(at index: Int) {
        guard (0 ..< listsSubject.value.count) ~= index else {
            preconditionFailure("Invalid index provided.")
        }

        listsSubject.value.remove(at: index)
    }

    public func setNeedsOpenList() {
        needsOpenListSubject.send()
    }
}
