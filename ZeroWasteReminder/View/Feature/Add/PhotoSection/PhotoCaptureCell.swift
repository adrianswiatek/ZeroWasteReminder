import Combine
import UIKit

public final class PhotoCaptureCell: UICollectionViewCell, ReuseIdentifiable {
    public var tap: AnyPublisher<Void, Never> {
        tapSubject.eraseToAnyPublisher()
    }

    public var cancellable: AnyCancellable?

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false

        let symbolConfiguration = UIImage.SymbolConfiguration(scale: .large)
        let image = UIImage.fromSymbol(.cameraFill, withConfiguration: symbolConfiguration)
        imageView.image = image.withColor(.secondaryLabel)

        return imageView
    }()

    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = .localized(.capture)
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()

    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .tertiarySystemFill
        view.clipsToBounds = true
        view.layer.cornerRadius = 8
        return view
    }()

    private let tapSubject: PassthroughSubject<Void, Never>

    public override init(frame: CGRect) {
        self.tapSubject = .init()
        super.init(frame: frame)
        self.setupView()
        self.addGestureRecognizer()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    private final func setupView() {
        let layoutGuide = UILayoutGuide()
        addLayoutGuide(layoutGuide)
        NSLayoutConstraint.activate([
            layoutGuide.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 4),
            layoutGuide.heightAnchor.constraint(equalToConstant: 8)
        ])

        contentView.addSubview(containerView)
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8)
        ])

        contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.bottomAnchor.constraint(equalTo: layoutGuide.topAnchor),
            imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        ])

        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: layoutGuide.bottomAnchor),
            label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
    }

    private func addGestureRecognizer() {
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleCellPressing))
        gestureRecognizer.minimumPressDuration = 0
        contentView.addGestureRecognizer(gestureRecognizer)
    }

    @objc
    private func handleCellPressing(_ gestureRecognizer: UILongPressGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            animatePressing(withAlpha: 0.33)
        case .ended:
            sendTapEventIfApplied(for: gestureRecognizer)
            animatePressing(withAlpha: 1)
        default: break
        }
    }

    private func animatePressing(withAlpha alpha: CGFloat) {
        UIView.animate(withDuration: 0.2) {
            self.imageView.alpha = alpha
            self.label.alpha = alpha
        }
    }

    private func sendTapEventIfApplied(for gestureRecognizer: UILongPressGestureRecognizer) {
        let location = gestureRecognizer.location(in: contentView)
        guard location.x >= 0 && location.y >= 0 else { return }

        let viewBounds = contentView.bounds
        guard location.x <= viewBounds.width else { return }
        guard location.y <= viewBounds.height else { return }

        tapSubject.send()
    }
}
