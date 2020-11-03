import Combine
import UIKit

public final class AlertSectionView: UIView {
    public var alertButtonTap: AnyPublisher<Void, Never> {
        button.tap
    }

    public var infoButtonTap: AnyPublisher<Void, Never> {
        noConsentView.infoButtonTap
    }

    private let label: UILabel
    private let button: AlertButton
    private let noConsentView: NoConsentForAlertsView

    public init() {
        self.label = .defaultWithText(.localized(.alert))
        self.button = .init(type: .system)
        self.noConsentView = .init()

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

    public func setEditability(_ isEditable: Bool) {
        button.isHidden = !isEditable
        noConsentView.isHidden = isEditable
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
            button.topAnchor.constraint(equalTo: label.bottomAnchor, constant: Metrics.spacing),
            button.leadingAnchor.constraint(equalTo: leadingAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        addSubview(noConsentView)
        NSLayoutConstraint.activate([
            noConsentView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: Metrics.spacing),
            noConsentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            noConsentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            noConsentView.trailingAnchor.constraint(equalTo: trailingAnchor)
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
