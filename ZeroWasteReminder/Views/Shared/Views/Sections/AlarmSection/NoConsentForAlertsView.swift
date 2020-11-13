import Combine
import UIKit

public final class NoConsentForAlertsView: UIView {
    public var infoButtonTap: AnyPublisher<Void, Never> {
        infoButtonTapSubject.eraseToAnyPublisher()
    }

    private let backgroundView: UIView = configure(.init()) {
        $0.backgroundColor = .tertiarySystemFill
        $0.layer.cornerRadius = 8
    }

    private let label: UILabel = configure(.init()) {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = .secondaryLabel
        $0.text = .localized(.thisOptionIsDisabled)
        $0.font = .systemFont(ofSize: 14, weight: .light)
        $0.numberOfLines = 0
    }

    private lazy var infoButton: UIButton = configure(.init(type: .system)) {
        $0.translatesAutoresizingMaskIntoConstraints = false

        let symbolConfiguration = UIImage.SymbolConfiguration(scale: .medium)
        let image = UIImage.fromSymbol(.exclamationmarkCircleFill, withConfiguration: symbolConfiguration)
        $0.setImage(image.withColor(.secondaryLabel), for: .normal)

        let action = UIAction { [weak self] _ in self?.infoButtonTapSubject.send() }
        $0.addAction(action, for: .touchUpInside)
    }

    private let infoButtonTapSubject: PassthroughSubject<Void, Never>

    public override init(frame: CGRect) {
        self.infoButtonTapSubject = .init()
        super.init(frame: frame)
        self.setupView()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false

        addAndFill(backgroundView)

        addSubview(infoButton)
        NSLayoutConstraint.activate([
            infoButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            infoButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: infoButton.leadingAnchor, constant: -16),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
