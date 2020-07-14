import Combine

public final class ListsViewModel {
    public var lists: AnyPublisher<[List], Never> {
        listsSubject.eraseToAnyPublisher()
    }

    public var needsRemoveList: AnyPublisher<List, Never> {
        needsRemoveListSubject.eraseToAnyPublisher()
    }

    public var needsChangeNameForList: AnyPublisher<(List, Int), Never> {
        needsChangeNameForListSubject.eraseToAnyPublisher()
    }

    public var needsOpenList: AnyPublisher<Void, Never> {
        needsOpenListSubject.eraseToAnyPublisher()
    }

    private let listsSubject: CurrentValueSubject<[List], Never>
    private let needsRemoveListSubject: PassthroughSubject<List, Never>
    private let needsChangeNameForListSubject: PassthroughSubject<(List, Int), Never>
    private let needsOpenListSubject: PassthroughSubject<Void, Never>

    public init() {
        listsSubject = .init([])
        needsRemoveListSubject = .init()
        needsChangeNameForListSubject = .init()
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

    public func removeList(_ list: List) {
        listsSubject.value.removeAll { $0 == list }
    }

    public func setNeedsRemoveList(at index: Int) {
        validate(index)
        needsRemoveListSubject.send(listsSubject.value[index])
    }

    public func setNeedsChangeNameForList(at index: Int) {
        validate(index)
        needsChangeNameForListSubject.send((listsSubject.value[index], index))
    }

    public func setNeedsOpenList() {
        needsOpenListSubject.send()
    }

    private func validate(_ index: Int) {
        let isValid = (0 ..< listsSubject.value.count) ~= index
        if !isValid { preconditionFailure("Invalid index provided.") }
    }
}
