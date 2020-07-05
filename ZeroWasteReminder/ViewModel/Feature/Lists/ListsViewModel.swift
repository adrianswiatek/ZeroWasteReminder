import Combine

public final class ListsViewModel {
    public var needsOpenList: AnyPublisher<Void, Never> {
        needsOpenListSubject.eraseToAnyPublisher()
    }

    private let needsOpenListSubject: PassthroughSubject<Void, Never>

    public init() {
        needsOpenListSubject = .init()
    }

    public func createList() {
        print("Create list...")
    }

    public func setNeedsOpenList() {
        needsOpenListSubject.send()
    }
}
