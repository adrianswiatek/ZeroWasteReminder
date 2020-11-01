import Combine

public final class SearchBarViewModel {
    @Published var searchTerm: String

    public var dismissTap: AnyPublisher<Void, Never> {
        dismissTapSubject.eraseToAnyPublisher()
    }

    private let dismissTapSubject: PassthroughSubject<Void, Never>
    private var subscriptions: Set<AnyCancellable>

    public init() {
        self.searchTerm = ""

        self.dismissTapSubject = .init()
        self.subscriptions = []
    }

    public func dismissTapped() {
        dismissTapSubject.send()
    }
}
