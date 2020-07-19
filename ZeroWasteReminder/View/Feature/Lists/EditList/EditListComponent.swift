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
    private let actionSubject: CurrentValueSubject<Action, Never>
    private var subscriptions: Set<AnyCancellable>

    private let viewModel: ListsViewModel

    public init(viewModel: ListsViewModel) {
        self.viewModel = viewModel

        self.textFieldView = .init()
        self.buttonsView = .init()
        self.overlayView = .init()

        self.stateSubject = .init(.idle)
        self.actionSubject = .init(.unspecified)
        self.subscriptions = []

        self.bind()
    }

    private func bind() {
        stateSubject
            .sink { [weak self] in self?.setState(to: $0) }
            .store(in: &subscriptions)

        textFieldView.isCurrentlyEditing
            .sink { [weak self] in self?.stateSubject.send(.active(editing: $0)) }
            .store(in: &subscriptions)

        buttonsView.addTapped
            .sink { [weak self] in
                self?.actionSubject.send(.creating)
                self?.stateSubject.send(.active(editing: false))
            }
            .store(in: &subscriptions)

        buttonsView.dismissTapped
            .sink { [weak self] in
                guard let self = self else { return }
                self.actionSubject.value.discard(in: self.viewModel)
                self.actionSubject.send(.unspecified)
                self.stateSubject.send(.idle)
            }
            .store(in: &subscriptions)

        buttonsView.confirmTapped.merge(with: textFieldView.doneTapped)
            .compactMap { [weak self] in self?.textFieldView.text }
            .sink { [weak self] in
                guard let self = self else { return }
                self.actionSubject.value.confirm(with: $0, in: self.viewModel)
                self.actionSubject.send(.unspecified)
                self.stateSubject.send(.idle)
            }
            .store(in: &subscriptions)

        viewModel.requestsSubject
            .compactMap { request -> List? in
                guard case .changeName(let list) = request else { return nil }
                return list
            }
            .receive(on: DispatchQueue.main)
            .flatMap { [weak self] list -> AnyPublisher<List, Never> in
                self?.actionSubject.send(.updating(list))
                self?.stateSubject.send(.active(editing: true))
                return Just<List>(list).eraseToAnyPublisher()
            }
            .delay(for: .milliseconds(200), scheduler: DispatchQueue.main)
            .sink { [weak self] in self?.textFieldView.text = $0.name }
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

    internal enum Action {
        case creating, updating(_ list: List), unspecified

        internal func confirm(with name: String, in viewModel: ListsViewModel) {
            if case .creating = self {
                viewModel.addList(withName: name)
            } else if case .updating(let list) = self {
                let updatedList = list.withName(name)
                updatedList != list ? update(updatedList, in: viewModel) : discard(in: viewModel)
            }
        }

        internal func update(_ list: List, in viewModel: ListsViewModel) {
            viewModel.updateList(list)
        }

        internal func discard(in viewModel: ListsViewModel) {
            viewModel.requestsSubject.send(.discardChanges)
        }
    }
}
