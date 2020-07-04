import Combine
import UIKit

public final class PhotoCaptureView: UIView {
    public var tap: AnyPublisher<PhotoCaptureTarget, Never> {
        tapSubject.eraseToAnyPublisher()
    }

    private let cameraButton: UIButton = .withSymbol(.cameraFill)
    private let galleryButton: UIButton = .withSymbol(.photoOnRectangleFill)

    private let tapSubject: PassthroughSubject<PhotoCaptureTarget, Never>

    public init() {
        tapSubject = .init()

        super.init(frame: .zero)

        setupView()
        setupActions()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false

        let layoutGuide = UILayoutGuide()
        addLayoutGuide(layoutGuide)
        NSLayoutConstraint.activate([
            layoutGuide.centerYAnchor.constraint(equalTo: centerYAnchor),
            layoutGuide.heightAnchor.constraint(equalToConstant: 8)
        ])

        addSubview(cameraButton)
        NSLayoutConstraint.activate([
            cameraButton.topAnchor.constraint(equalTo: topAnchor),
            cameraButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            cameraButton.bottomAnchor.constraint(equalTo: layoutGuide.topAnchor),
            cameraButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8)
        ])

        addSubview(galleryButton)
        NSLayoutConstraint.activate([
            galleryButton.topAnchor.constraint(equalTo: layoutGuide.bottomAnchor),
            galleryButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            galleryButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            galleryButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8)
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
