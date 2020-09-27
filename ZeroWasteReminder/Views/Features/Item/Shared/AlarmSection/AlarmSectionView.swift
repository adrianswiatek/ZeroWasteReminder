import Combine
import UIKit

public final class AlarmSectionView: UIView {
    public var tap: AnyPublisher<Void, Never> {
        button.tap
    }

    private let label: UILabel
    private let button: AlarmButton

    private var subscriptions: Set<AnyCancellable>

    public init() {
        self.label = .defaultWithText(.localized(.alarm))
        self.button = .init(type: .system)
        self.subscriptions = []

        super.init(frame: .zero)

        self.setupView()
        self.button.setTitle("1 day before", for: .normal)
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

private extension AlarmSectionView {
    enum Metrics {
        static let spacing: CGFloat = 8
    }
}
