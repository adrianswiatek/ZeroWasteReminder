import UIKit

public final class WarningBarView: UIView {
    public var height: CGFloat {
        heightConstraint?.constant ?? 0
    }

    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = .localized(.cannotConnectToICloud)
        label.textColor = .white
        label.font = .systemFont(ofSize: 16)
        return label
    }()

    private var heightConstraint: NSLayoutConstraint?

    public init() {
        super.init(frame: .zero)
        self.setupView()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    public func setText(_ text: String) {
        label.text = text
    }

    public func setVisibility(_ isVisible: Bool) {
        heightConstraint?.constant = isVisible ? Metrics.visibleHeight : Metrics.hiddenHeight
        animateLayout()
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .almostExpired
        layer.cornerRadius = 8

        addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        heightConstraint = heightAnchor.constraint(equalToConstant: Metrics.hiddenHeight)
        heightConstraint?.isActive = true
    }

    private func animateLayout() {
        UIView.animate(
            withDuration: 0.3,
            animations: { self.window?.layoutIfNeeded()},
            completion: { _ in self.label.isHidden = self.height == Metrics.hiddenHeight }
        )

        UIView.animate(withDuration: 0.3) {
            self.window?.layoutIfNeeded()
        }
    }
}

private extension WarningBarView {
    enum Metrics {
        static let visibleHeight: CGFloat = 32
        static let hiddenHeight: CGFloat = 0
    }
}
