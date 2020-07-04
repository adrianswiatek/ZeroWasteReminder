import Combine
import UIKit

public final class ListCell: UICollectionViewCell, ReuseIdentifiable {
    public var tap: AnyPublisher<Void, Never> {
        tapSubject.eraseToAnyPublisher()
    }

    public var subscription: AnyCancellable?

    private lazy var listNameButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleEdgeInsets = .init(top: 0, left: 24, bottom: 0, right: 0)
        button.contentHorizontalAlignment = .leading
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        button.titleLabel?.textAlignment = .left
        button.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        return button
    }()

    private let chevronImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false

        let configuration = UIImage.SymbolConfiguration(scale: .medium)
        let image = UIImage.fromSymbol(.chevronRight, withConfiguration: configuration)
        imageView.image = image.withColor(.secondaryLabel)

        return imageView
    }()

    private let tapSubject: PassthroughSubject<Void, Never>

    public override init(frame: CGRect) {
        self.tapSubject = .init()

        super.init(frame: frame)

        self.setupView()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    public func setListName(_ listName: String) {
        listNameButton.setTitle(listName, for: .normal)
    }

    private func setupView() {
        backgroundColor = .systemBackground

        layer.shadowOpacity = 0.24
        layer.shadowRadius = 5
        layer.shadowOffset = .init(width: 0, height: 2)

        layer.cornerRadius = 8

        contentView.addSubview(listNameButton)
        NSLayoutConstraint.activate([
            listNameButton.topAnchor.constraint(equalTo: contentView.topAnchor),
            listNameButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            listNameButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])

        contentView.addSubview(chevronImageView)
        NSLayoutConstraint.activate([
            chevronImageView.leadingAnchor.constraint(equalTo: listNameButton.trailingAnchor),
            chevronImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            chevronImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    @objc
    private func handleTap() {
        tapSubject.send()
    }
}
