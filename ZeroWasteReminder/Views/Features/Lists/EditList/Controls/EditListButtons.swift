import Combine
import UIKit

internal final class EditListButtons: UIView {
    public var addTapped: AnyPublisher<Void, Never> {
        mixedButton.addTapped
    }

    public var confirmTapped: AnyPublisher<Void, Never> {
        confirmButton.tap
    }

    public var dismissTapped: AnyPublisher<Void, Never> {
        mixedButton.dismissTapped
    }

    public override var intrinsicContentSize: CGSize {
        .init(width: Metrics.buttonDiameter * 2.5, height: Metrics.buttonDiameter)
    }

    private lazy var mixedButtonTrailingConstraint: NSLayoutConstraint =
        mixedButton.trailingAnchor.constraint(equalTo: trailingAnchor)

    private let confirmButton: EditListConfirmButton
    private let mixedButton: EditListMixedButton

    private var subscriptions: Set<AnyCancellable>

    internal override init(frame: CGRect) {
        self.confirmButton = .init()
        self.mixedButton = .init()
        self.subscriptions = []

        super.init(frame: frame)

        self.setupView()
    }

    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("Not supported")
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false

        configure(confirmButton)
        configure(mixedButton)

        addSubview(confirmButton)
        NSLayoutConstraint.activate([
            confirmButton.topAnchor.constraint(equalTo: topAnchor),
            confirmButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            confirmButton.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        addSubview(mixedButton)
        NSLayoutConstraint.activate([
            mixedButton.topAnchor.constraint(equalTo: topAnchor),
            mixedButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            mixedButtonTrailingConstraint
        ])
    }
}

private extension EditListButtons {
    func configure(_ button: UIButton) {
        button.translatesAutoresizingMaskIntoConstraints = false
        button.alpha = 0.85
        button.backgroundColor = .accent
        button.tintColor = .white
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)

        button.layer.cornerRadius = Metrics.buttonDiameter / 2

        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: Metrics.buttonDiameter),
            button.widthAnchor.constraint(equalToConstant: Metrics.buttonDiameter)
        ])
    }
}

extension EditListButtons: EditListControl {
    private enum Metrics {
        static let buttonDiameter: CGFloat = 52
    }

    internal func setState(to state: EditListComponent.State) {
        mixedButton.setState(to: state)
        confirmButton.setState(to: state)

        updateView(with: state)
    }

    private func updateView(with state: EditListComponent.State) {
        mixedButtonTrailingConstraint.constant = trailingConstant(for: state)

        UIView.animate(
            withDuration: 0.75,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0,
            options: .curveEaseOut,
            animations: { self.layoutIfNeeded() }
        )
    }

    private func trailingConstant(for state: EditListComponent.State) -> CGFloat {
        if case .active(let editing) = state, editing {
            return -72
        } else {
            return 0
        }
    }
}
