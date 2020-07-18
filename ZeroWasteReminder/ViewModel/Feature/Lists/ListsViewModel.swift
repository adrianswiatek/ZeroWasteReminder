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

    private let listsRepository: ListsRepository
    private var subscriptions: Set<AnyCancellable>

    public init(listsRepository: ListsRepository) {
        self.listsRepository = listsRepository
        self.subscriptions = []

        self.listsSubject = .init([])

        self.needsDiscardChangesSubject = .init()
        self.needsRemoveListSubject = .init()
        self.needsChangeNameForListSubject = .init()
        self.needsOpenListSubject = .init()

        self.bind()
    }

    public func addList(withName name: String) {
        listsRepository.add(.init(name: name))
    }

    public func updateList(_ list: List) {
        listsRepository.update(list)
    }

    public func removeList(_ list: List) {
        listsRepository.remove(list)
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

    private func bind() {
        listsRepository.lists
            .subscribe(listsSubject)
            .store(in: &subscriptions)
    }

    private func validate(_ index: Int) {
        let isValid = (0 ..< listsSubject.value.count) ~= index
        if !isValid { preconditionFailure("Invalid index provided.") }
    }
}
