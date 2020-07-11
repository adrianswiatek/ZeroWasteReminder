import Combine
import UIKit

public final class NewListComponent {
    public var textField: UIView {
        newsListTextField
    }

    public var button: UIView {
        newsListButton
    }

    public var overlay: UIView {
        newsListOverlayView
    }

    private let newsListTextField: NewListTextField
    private let newsListButton: NewListButton
    private let newsListOverlayView: NewListOverlayView

    private let stateSubject: CurrentValueSubject<State, Never>
    private var subscriptions: Set<AnyCancellable>

    public init() {
        newsListTextField = .init()
        newsListButton = .init()
        newsListOverlayView = .init()

        stateSubject = .init(.idle)
        subscriptions = []

        bind()
    }

    private func bind() {
        stateSubject
            .sink { [weak self] in self?.setState(to: $0) }
            .store(in: &subscriptions)

        newsListTextField.cancelEditing
            .map { State.idle }
            .subscribe(stateSubject)
            .store(in: &subscriptions)

        newsListButton.tap
            .compactMap { [weak self] in self?.stateSubject.value.toggled() }
            .subscribe(stateSubject)
            .store(in: &subscriptions)
    }

    private func setState(to state: State) {
        newsListTextField.setState(to: state)
        newsListButton.setState(to: state)
        newsListOverlayView.setState(to: state)
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
