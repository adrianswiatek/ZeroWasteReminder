import Combine
import UIKit

public final class EditListComponent {
    public var textField: UIView {
        textFieldView
    }

    public var buttons: UIView {
        buttonsView
    }

    public var overlay: UIView {
        overlayView
    }

    private let textFieldView: EditListTextField
    private let buttonsView: EditListButtons
    private let overlayView: EditListOverlayView

    private let stateSubject: CurrentValueSubject<State, Never>
    private var subscriptions: Set<AnyCancellable>

    private let viewModel: ListsViewModel

    public init(viewModel: ListsViewModel) {
        self.viewModel = viewModel
        self.textFieldView = .init()
        self.buttonsView = .init()
        self.overlayView = .init()

        self.stateSubject = .init(.idle)
        self.subscriptions = []

        self.bind()
    }

    private func bind() {
        stateSubject
            .sink { [weak self] in self?.setState(to: $0) }
            .store(in: &subscriptions)

        textFieldView.isCurrentlyEditing
            .map { State.active(editing: $0) }
            .subscribe(stateSubject)
            .store(in: &subscriptions)

        buttonsView.addTapped
            .map { State.active(editing: false) }
            .subscribe(stateSubject)
            .store(in: &subscriptions)

        buttonsView.dismissTapped
            .map { State.idle }
            .subscribe(stateSubject)
            .store(in: &subscriptions)

        buttonsView.confirmTapped.merge(with: textFieldView.doneTapped)
            .compactMap { [weak self] in self?.textFieldView.text }
            .sink { [weak self] in self?.viewModel.addList(withName: $0) }
            .store(in: &subscriptions)

        buttonsView.confirmTapped.merge(with: textFieldView.doneTapped)
            .map { State.idle }
            .subscribe(stateSubject)
            .store(in: &subscriptions)
    }

    private func setState(to state: State) {
        textFieldView.setState(to: state)
        buttonsView.setState(to: state)
        overlayView.setState(to: state)
    }
}

extension EditListComponent {
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
