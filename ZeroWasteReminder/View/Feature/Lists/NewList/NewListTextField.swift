import Combine
import UIKit

public final class NewListTextField: UITextField {
    public var cancelEditing: AnyPublisher<Void, Never> {
        textSubject.filter { $0.isEmpty }.map { _ in }.eraseToAnyPublisher()
    }

    private lazy var heightConstraint: NSLayoutConstraint =
        heightAnchor.constraint(equalToConstant: .zero)

    private let textSubject: CurrentValueSubject<String, Never>
    private let isVisibleSubject: CurrentValueSubject<Bool, Never>
    private var subscriptions: Set<AnyCancellable>

    public init() {
        self.textSubject = .init("")
        self.isVisibleSubject = .init(false)
        self.subscriptions = .init()

        super.init(frame: .zero)

        self.setupView()
        self.bind()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    public override func editingRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: .init(top: 0, left: 16, bottom: 0, right: -16))
    }

    public override func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: .init(top: 0, left: 16, bottom: 0, right: -16))
    }

    public func setState(to state: NewListComponent.State) {
        isVisibleSubject.send(state == .active)
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .secondarySystemBackground
        placeholder = .localized(.listName)
        returnKeyType = .done
        tintColor = .accent
        delegate = self

        layer.cornerRadius = 8

        heightConstraint.isActive = true
    }

    private func bind() {
        textSubject
            .sink { [weak self] _ in self?.text = "" }
            .store(in: &subscriptions)

        isVisibleSubject
            .map { $0 ? Metric.visibleHeight : .zero }
            .assign(to: \.constant, on: heightConstraint)
            .store(in: &subscriptions)

        isVisibleSubject
            .dropFirst(2)
            .sink { [weak self] _ in UIView.animate(withDuration: 0.3) {
                self?.superview?.layoutIfNeeded()
            }}
            .store(in: &subscriptions)

        isVisibleSubject
            .delay(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] in _ = $0 ? self?.becomeFirstResponder() : self?.resignFirstResponder() }
            .store(in: &subscriptions)
    }

    private func cancel() {
        textSubject.send("")
        resignFirstResponder()
    }
}

extension NewListTextField: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        cancel()
        return true
    }
}

private extension NewListTextField {
    enum Metric {
        static let visibleHeight: CGFloat = 44
    }
}
