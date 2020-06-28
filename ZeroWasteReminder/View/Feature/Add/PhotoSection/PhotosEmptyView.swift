import Combine
import UIKit

public final class PhotosEmptyView: UIView {
    public var tap: AnyPublisher<PhotoCaptureTarget, Never> {
        photoCaptureView.tap.eraseToAnyPublisher()
    }

    private let photoCaptureView: PhotoCaptureView

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .tertiaryLabel

        let symbolConfiguration = UIImage.SymbolConfiguration(scale: .large)
        imageView.image = .fromSymbol(.photoOnRectangle, withConfiguration: symbolConfiguration)

        return imageView
    }()

    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = .localized(.noPhotosToShow)
        label.textColor = .tertiaryLabel
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 15)
        return label
    }()

    private let backgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false

        view.layer.borderColor = UIColor.tertiarySystemFill.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 8

        return view
    }()

    public init() {
        photoCaptureView = .init()
        super.init(frame: .zero)
        setupView()
    }

    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    public override var intrinsicContentSize: CGSize {
        .init(width: super.intrinsicContentSize.width, height: 96)
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(photoCaptureView)
        NSLayoutConstraint.activate([
            photoCaptureView.topAnchor.constraint(equalTo: topAnchor),
            photoCaptureView.leadingAnchor.constraint(equalTo: leadingAnchor),
            photoCaptureView.bottomAnchor.constraint(equalTo: bottomAnchor),
            photoCaptureView.widthAnchor.constraint(equalToConstant: 72)
        ])

        addSubview(backgroundView)
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: photoCaptureView.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        backgroundView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor, constant: -12)
        ])

        backgroundView.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 12),
            label.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor)
        ])
    }
}
