import Combine

public final class AlertViewModel {
    @Published public private(set) var selectedOption: AlertOption
    public let requestSubject: PassthroughSubject<Request, Never>

    public let options: [AlertOption] = [
        .none,
        .onDayOfExpiration,
        .daysBefore(1),
        .daysBefore(2),
        .daysBefore(3),
        .weeksBefore(1),
        .weeksBefore(2),
        .monthsBefore(1),
        .customDate
    ]

    private let eventDispatcher: EventDispatcher
    private var subscriptions: Set<AnyCancellable>

    public init(selectedOption: AlertOption, eventDispatcher: EventDispatcher) {
        self.selectedOption = selectedOption
        self.eventDispatcher = eventDispatcher

        self.requestSubject = .init()
        self.subscriptions = []
        self.bind()
    }

    public func indexOf(_ option: AlertOption) -> Int? {
        options.firstIndex(of: option)
    }

    public func selectOption(at index: Int) {
        assert(index >= 0 && index < options.count, "Invalid index.")

        selectedOption = options[index]
        if selectedOption != .customDate {
            requestSubject.send(.dismiss)
        }
    }

    private func bind() {
        $selectedOption
            .dropFirst()
            .sink { [weak self] in self?.eventDispatcher.dispatch(AlertSet($0)) }
            .store(in: &subscriptions)
    }
}

public extension AlertViewModel {
    enum Request {
        case dismiss
    }
}
