import Combine
import UIKit

public final class ActionsSectionView: UIView {
    public var removeButtonTap: AnyPublisher<Void, Never> {
        removeButton.tap
    }

    public var moveButtonTap: AnyPublisher<Void, Never> {
        moveButton.tap
    }

    private let label: UILabel

    private let removeButton: ActionButton
    private let moveButton: ActionButton

    public init() {
        self.label = .defaultWithText(.localized(.actions))
        self.removeButton = .remove
        self.moveButton = .move

        super.init(frame: .zero)

        self.setupView()
    }

    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor)
        ])

        let stackView = UIStackView(arrangedSubviews: [removeButton, moveButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 8
        stackView.distribution = .fillEqually

        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: Metrics.spacing),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}

private extension ActionsSectionView {
    enum Metrics {
        static let spacing: CGFloat = 8
    }
}
