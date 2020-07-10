import Combine
import UIKit

public final class NewListComponent {
    public let textField: NewListTextField
    public let greenButton: NewListButton

    private let stateSubject: CurrentValueSubject<State, Never>
    private var subscriptions: Set<AnyCancellable>

    public init() {
        textField = .init()
        greenButton = .init()

        stateSubject = .init(.idle)
        subscriptions = []

        bind()
    }

    private func bind() {
        stateSubject
            .sink { [weak self] in self?.setState(to: $0) }
            .store(in: &subscriptions)

        textField.cancelEditing
            .map { State.idle }
            .subscribe(stateSubject)
            .store(in: &subscriptions)

        greenButton.tap
            .compactMap { [weak self] in self?.stateSubject.value.toggled() }
            .subscribe(stateSubject)
            .store(in: &subscriptions)
    }

    private func setState(to state: State) {
        textField.setState(to: state)
        greenButton.setState(to: state)
    }
}

extension NewListComponent {
    public enum State {
        case idle, active

        public func toggled() -> State {
            switch self {
            case .idle: return .active
            case .active: return .idle
            }
        }
    }
}
