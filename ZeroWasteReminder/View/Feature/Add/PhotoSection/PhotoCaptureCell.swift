import Combine
import UIKit

public final class PhotoCaptureCell: UICollectionViewCell, ReuseIdentifiable {
    public var tap: AnyPublisher<PhotoCaptureTarget, Never> {
        tapSubject.eraseToAnyPublisher()
    }

    public var cancellable: AnyCancellable?

    private let cameraButton: UIButton = .withSymbol(.cameraFill)
    private let galleryButton: UIButton = .withSymbol(.photoOnRectangle)

    private let tapSubject: PassthroughSubject<PhotoCaptureTarget, Never>

    public override init(frame: CGRect) {
        self.tapSubject = .init()
        super.init(frame: frame)
        self.setupView()
        self.setupActions()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    private final func setupView() {
        let layoutGuide = UILayoutGuide()
        addLayoutGuide(layoutGuide)
        NSLayoutConstraint.activate([
            layoutGuide.centerYAnchor.constraint(equalTo: centerYAnchor),
            layoutGuide.heightAnchor.constraint(equalToConstant: 8)
        ])

        contentView.addSubview(cameraButton)
        NSLayoutConstraint.activate([
            cameraButton.topAnchor.constraint(equalTo: contentView.topAnchor),
            cameraButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cameraButton.bottomAnchor.constraint(equalTo: layoutGuide.topAnchor),
            cameraButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8)
        ])

        contentView.addSubview(galleryButton)
        NSLayoutConstraint.activate([
            galleryButton.topAnchor.constraint(equalTo: layoutGuide.bottomAnchor),
            galleryButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            galleryButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            galleryButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8)
        ])
    }

    private func setupActions() {
        cameraButton.addTarget(self, action: #selector(handleCameraButtonTap), for: .touchUpInside)
        galleryButton.addTarget(self, action: #selector(handleGalleryButtonTap), for: .touchUpInside)
    }

    @objc
    private func handleCameraButtonTap() {
        tapSubject.send(.camera)
    }

    @objc
    private func handleGalleryButtonTap() {
        tapSubject.send(.photoLibrary)
    }
}

private extension UIButton {
    static func withSymbol(_ symbol: UIImage.Symbol) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .tertiarySystemFill
        button.clipsToBounds = true
        button.layer.cornerRadius = 8

        let symbolConfiguration = UIImage.SymbolConfiguration(scale: .large)
        let image = UIImage.fromSymbol(symbol, withConfiguration: symbolConfiguration)
        button.setImage(image.withColor(.label), for: .normal)

        return button
    }
}
