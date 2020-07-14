import Combine
import UIKit

public final class NewListComponent {
    public var textField: UIView {
        newListTextField
    }

    public var buttons: UIView {
        newListButtons
    }

    public var overlay: UIView {
        newListOverlayView
    }

    private let newListTextField: NewListTextField
    private let newListButtons: NewListButtons
    private let newListOverlayView: NewListOverlayView

    private let stateSubject: CurrentValueSubject<State, Never>
    private var subscriptions: Set<AnyCancellable>

    private let viewModel: ListsViewModel

    public init(viewModel: ListsViewModel) {
        self.viewModel = viewModel
        self.newListTextField = .init()
        self.newListButtons = .init()
        self.newListOverlayView = .init()

        self.stateSubject = .init(.idle)
        self.subscriptions = []

        self.bind()
    }

    private func bind() {
        stateSubject
            .sink { [weak self] in self?.setState(to: $0) }
            .store(in: &subscriptions)

        newListTextField.isCurrentlyEditing
            .map { State.active(editing: $0) }
            .subscribe(stateSubject)
            .store(in: &subscriptions)

        newListButtons.addTapped
            .map { State.active(editing: false) }
            .subscribe(stateSubject)
            .store(in: &subscriptions)

        newListButtons.dismissTapped
            .map { State.idle }
            .subscribe(stateSubject)
            .store(in: &subscriptions)

        newListButtons.confirmTapped.merge(with: newListTextField.doneTapped)
            .compactMap { [weak self] in self?.newListTextField.text }
            .sink { [weak self] in self?.viewModel.addList(withName: $0) }
            .store(in: &subscriptions)

        newListButtons.confirmTapped.merge(with: newListTextField.doneTapped)
            .map { State.idle }
            .subscribe(stateSubject)
            .store(in: &subscriptions)
    }

    private func setState(to state: State) {
        newListTextField.setState(to: state)
        newListButtons.setState(to: state)
        newListOverlayView.setState(to: state)
    }
}

extension NewListComponent {
    internal enum State: Equatable {
        case idle, active(editing: Bool)

        internal static func ==(lhs: State, rhs: State) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle):
                return true
            case let (.active(leftEditing), .active(rightEditing)):
                return leftEditing == rightEditing
            default:
                return false
            }
        }
    }
}
