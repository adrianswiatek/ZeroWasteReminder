import Combine
import UIKit

public final class ListCell: UICollectionViewCell, ReuseIdentifiable {
    public var tap: AnyPublisher<Void, Never> {
        tapSubject.eraseToAnyPublisher()
    }

    public var subscription: AnyCancellable?

    private let listNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.textAlignment = .left
        return label
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
        self.setupGestureRecognizer()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    public func setListName(_ listName: String) {
        listNameLabel.text = listName
    }

    private func setupView() {
        backgroundColor = .secondarySystemBackground

        layer.shadowOpacity = 0.24
        layer.shadowRadius = 5
        layer.shadowOffset = .init(width: 0, height: 2)

        layer.cornerRadius = 8

        contentView.addSubview(listNameLabel)
        NSLayoutConstraint.activate([
            listNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            listNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            listNameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])

        contentView.addSubview(chevronImageView)
        NSLayoutConstraint.activate([
            chevronImageView.leadingAnchor.constraint(equalTo: listNameLabel.trailingAnchor),
            chevronImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            chevronImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    private func setupGestureRecognizer() {
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleTap))
        gestureRecognizer.minimumPressDuration = 0.15
        gestureRecognizer.cancelsTouchesInView = false
        contentView.addGestureRecognizer(gestureRecognizer)
    }

    @objc
    private func handleTap(gestureRecognizer: UILongPressGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began: animateComponents(withAlpha: 0.25)
        case .ended: animateComponents(withAlpha: 1)
        default: break
        }
    }

    private func animateComponents(withAlpha alpha: CGFloat) {
        UIView.animate(withDuration: 0.15) {
            self.listNameLabel.alpha = alpha
            self.chevronImageView.alpha = alpha
        }
    }
}
