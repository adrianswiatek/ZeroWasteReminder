import Combine

public final class ListsViewModel {
    private let listsSubject: CurrentValueSubject<[List], Never>
    public var lists: AnyPublisher<[List], Never> {
        listsSubject.eraseToAnyPublisher()
    }

    private let needsDiscardChangesSubject: PassthroughSubject<Void, Never>
    public var needsDiscardChanges: AnyPublisher<Void, Never> {
        needsDiscardChangesSubject.eraseToAnyPublisher()
    }

    private let needsRemoveListSubject: PassthroughSubject<List, Never>
    public var needsRemoveList: AnyPublisher<List, Never> {
        needsRemoveListSubject.eraseToAnyPublisher()
    }

    private let needsChangeNameForListSubject: PassthroughSubject<(List, Int), Never>
    public var needsChangeNameForList: AnyPublisher<(List, Int), Never> {
        needsChangeNameForListSubject.eraseToAnyPublisher()
    }

    private let needsOpenListSubject: PassthroughSubject<Void, Never>
    public var needsOpenList: AnyPublisher<Void, Never> {
        needsOpenListSubject.eraseToAnyPublisher()
    }

    public init() {
        listsSubject = .init([])
        needsDiscardChangesSubject = .init()
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

    public func updateList(_ list: List) {
        listsSubject.value
            .firstIndex { $0.id == list.id }
            .map { listsSubject.value[$0] = list }
    }

    public func removeList(_ list: List) {
        listsSubject.value.removeAll { $0 == list }
    }

    public func setNeedsDiscardChanges() {
        needsDiscardChangesSubject.send()
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
