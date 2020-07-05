import Combine
import UIKit

public final class NewListCell: UICollectionViewCell, ReuseIdentifiable {
    public var tap: AnyPublisher<Void, Never> {
        tapSubject.eraseToAnyPublisher()
    }

    private lazy var button: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentHorizontalAlignment = .leading
        button.addTarget(self, action: #selector(handleTap), for: .touchUpInside)

        let symbolConfiguration = UIImage.SymbolConfiguration(scale: .large)
        let image = UIImage.fromSymbol(.textBadgePlus, withConfiguration: symbolConfiguration)
        button.setImage(image.withColor(.label), for: .normal)
        button.imageEdgeInsets = .init(top: 0, left: 24, bottom: 0, right: 0)

        button.titleLabel?.font = .systemFont(ofSize: 18)
        button.setTitleColor(.label, for: .normal)
        button.setTitle(.localized(.newList), for: .normal)
        button.titleEdgeInsets = .init(top: 0, left: 32, bottom: 0, right: 0)

        return button
    }()

    private let background: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .secondarySystemBackground
        view.layer.shadowOpacity = 0.24
        view.layer.shadowRadius = 5
        view.layer.shadowOffset = .init(width: 0, height: 2)
        view.layer.cornerRadius = 8
        return view
    }()

    private let tapSubject: PassthroughSubject<Void, Never>
    private var subscription: AnyCancellable?

    public override init(frame: CGRect) {
        self.tapSubject = .init()
        super.init(frame: frame)
        self.setupView()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    public func set(_ subscription: AnyCancellable) {
        self.subscription = subscription
    }

    private func setupView() {
        contentView.addSubview(background)
        NSLayoutConstraint.activate([
            background.topAnchor.constraint(equalTo: contentView.topAnchor),
            background.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            background.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            background.heightAnchor.constraint(equalToConstant: 48)
        ])

        background.addSubview(button)
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: background.topAnchor),
            button.leadingAnchor.constraint(equalTo: background.leadingAnchor),
            button.bottomAnchor.constraint(equalTo: background.bottomAnchor),
            button.trailingAnchor.constraint(equalTo: background.trailingAnchor)
        ])
    }

    @objc
    private func handleTap() {
        tapSubject.send()
    }
}
