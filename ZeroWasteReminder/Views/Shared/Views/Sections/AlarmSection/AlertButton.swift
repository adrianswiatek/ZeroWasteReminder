import Combine
import UIKit

public final class AlertButton: UIButton {
    public var tap: AnyPublisher<Void, Never> {
        tapSubject.eraseToAnyPublisher()
    }

    public override var intrinsicContentSize: CGSize {
        .init(width: super.intrinsicContentSize.width, height: Metrics.height)
    }

    private let chevronImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.setContentHuggingPriority(.defaultLow + 1, for: .horizontal)

        let symbolConfiguration = UIImage.SymbolConfiguration(scale: .small)
        let image = UIImage.fromSymbol(.chevronRight, withConfiguration: symbolConfiguration)
        imageView.image = image.withColor(.secondaryLabel)

        return imageView
    }()

    private let titleAttributes: [NSAttributedString.Key: Any] = {
        [.font: UIFont.systemFont(ofSize: 14, weight: .light)]
    }()

    private let tapSubject: PassthroughSubject<Void, Never>

    public override init(frame: CGRect) {
        self.tapSubject = .init()

        super.init(frame: .zero)

        self.setupView()
        self.setupTapGestureRecognizer()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    public func setText(_ text: String) {
        setAttributedTitle(.init(string: text, attributes: titleAttributes), for: .normal)
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .tertiarySystemFill

        layer.cornerRadius = Metrics.cornerRadius

        setTitleColor(.label, for: .normal)
        setAttributedTitle(.init(string: .localized(.none), attributes: titleAttributes), for: .normal)

        contentHorizontalAlignment = .leading
        contentEdgeInsets = .init(top: 0, left: Metrics.padding, bottom: 0, right: 0)

        addSubview(chevronImageView)
        NSLayoutConstraint.activate([
            chevronImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metrics.padding),
            chevronImageView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    private func setupTapGestureRecognizer() {
        addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(handleTap))
        )
    }

    @objc
    private func handleTap() {
        tapSubject.send()
    }
}

private extension AlertButton {
    enum Metrics {
        static let cornerRadius: CGFloat = 8
        static let height: CGFloat = 47
        static let padding: CGFloat = 12
    }
}
