import Combine
import UIKit

public final class AlertSectionView: UIView {
    public var tap: AnyPublisher<Void, Never> {
        button.tap
    }

    private let label: UILabel
    private let button: AlertButton

    public init() {
        self.label = .defaultWithText(.localized(.alert))
        self.button = .init(type: .system)

        super.init(frame: .zero)

        self.setupView()
    }

    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    public func setTitle(_ title: String) {
        button.setText(title)
    }

    public func setVisibility(_ isVisible: Bool) {
        if let superview = superview {
            UIView.transition(
                with: superview,
                duration: Duration.visibility,
                options: .transitionCrossDissolve,
                animations: { self.isHidden = !isVisible }
            )
            UIView.animate(
                withDuration: Duration.visibility,
                animations: { self.alpha = isVisible ? 1 : 0 }
            )
        } else {
            isHidden = !isVisible
        }
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor)
        ])

        addSubview(button)
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(
                equalTo: label.bottomAnchor, constant: Metrics.spacing
            ),
            button.leadingAnchor.constraint(equalTo: leadingAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}

private extension AlertSectionView {
    enum Metrics {
        static let spacing: CGFloat = 8
    }

    enum Duration {
        static let visibility: Double = 0.3
    }
}
