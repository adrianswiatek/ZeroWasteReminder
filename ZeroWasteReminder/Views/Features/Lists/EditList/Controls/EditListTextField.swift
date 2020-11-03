import Combine
import UIKit

internal final class EditListTextField: UITextField {
    internal var editingText: AnyPublisher<String, Never> {
        editingTextSubject.eraseToAnyPublisher()
    }

    internal var isCurrentlyEditing: AnyPublisher<Bool, Never> {
        editingTextSubject
            .filter { [weak self] _ in self?.isVisibleSubject.value == true }
            .map { !$0.isEmpty }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    internal var doneTapped: AnyPublisher<Void, Never> {
        doneTappedSubject.eraseToAnyPublisher()
    }

    private lazy var heightConstraint: NSLayoutConstraint =
        heightAnchor.constraint(equalToConstant: .zero)

    private let doneTappedSubject: PassthroughSubject<Void, Never>
    private let editingTextSubject: CurrentValueSubject<String, Never>
    private let isVisibleSubject: CurrentValueSubject<Bool, Never>

    private var subscriptions: Set<AnyCancellable>

    internal init() {
        self.doneTappedSubject = .init()
        self.editingTextSubject = .init("")
        self.isVisibleSubject = .init(false)
        self.subscriptions = .init()

        super.init(frame: .zero)

        self.setupView()
        self.bind()
    }

    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    internal override func editingRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: .init(top: 0, left: 16, bottom: 0, right: 16))
    }

    internal override func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: .init(top: 0, left: 16, bottom: 0, right: 16))
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .secondarySystemBackground
        placeholder = .localized(.listName)
        directionalLayoutMargins = .init(top: 0, leading: 16, bottom: 0, trailing: 16)
        clearButtonMode = .whileEditing
        returnKeyType = .done
        tintColor = .accent
        delegate = self

        layer.cornerRadius = 8

        heightConstraint.isActive = true
    }

    private func bind() {
        editingTextSubject
            .sink { [weak self] in self?.text = $0 }
            .store(in: &subscriptions)

        isVisibleSubject
            .map { $0 ? Metric.visibleHeight : .zero }
            .flatMap { [weak self] height -> AnyPublisher<CGFloat, Never> in
                self?.heightConstraint.constant = height
                return Just(height).eraseToAnyPublisher()
            }
            .sink { [weak self] _ in
                UIView.animate(withDuration: 0.3) { self?.superview?.layoutIfNeeded() }
            }
            .store(in: &subscriptions)

        isVisibleSubject
            .sink { [weak self] in $0 ? self?.beginEditing() : self?.finishEditing() }
            .store(in: &subscriptions)
    }

    private func beginEditing() {
        becomeFirstResponder()
    }

    private func finishEditing() {
        resignFirstResponder()
        editingTextSubject.send("")
    }
}

extension EditListTextField: EditListControl {
    internal func setState(to state: EditListComponent.State) {
        isVisibleSubject.send(state != .idle)
    }
}

extension EditListTextField: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard textField.text?.isEmpty == false else {
            return false
        }

        resignFirstResponder()
        doneTappedSubject.send()

        return true
    }

    public func textFieldDidChangeSelection(_ textField: UITextField) {
        editingTextSubject.send(textField.text ?? "")
    }
}

private extension EditListTextField {
    enum Metric {
        static let visibleHeight: CGFloat = 44
    }
}
