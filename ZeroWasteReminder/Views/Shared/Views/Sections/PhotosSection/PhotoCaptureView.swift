import Combine
import UIKit

public final class PhotoCaptureView: UIView {
    public var tap: AnyPublisher<PhotoCaptureTarget, Never> {
        tapSubject.eraseToAnyPublisher()
    }

    private lazy var cameraButton: UIButton = .withSymbol(.cameraFill) { [weak self] _ in
        self?.tapSubject.send(.camera)
        self?.cameraLoadingView.show()
    }

    private lazy var galleryButton: UIButton = .withSymbol(.photoOnRectangleFill) { [weak self] _ in
        self?.tapSubject.send(.photoLibrary)
        self?.galleryLoadingView.show()
    }

    private let cameraLoadingView: LoadingView = configure(.init()) {
        $0.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.5)
    }

    private let galleryLoadingView: LoadingView = configure(.init()) {
        $0.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.5)
    }

    private let tapSubject: PassthroughSubject<PhotoCaptureTarget, Never>

    public init() {
        tapSubject = .init()
        super.init(frame: .zero)
        setupView()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    public func hideActivityIndicators() {
        DispatchQueue.main.async {
            self.cameraLoadingView.hide()
            self.galleryLoadingView.hide()
        }
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

        cameraButton.addAndFill(cameraLoadingView)
        galleryButton.addAndFill(galleryLoadingView)
    }
}

private extension UIButton {
    static func withSymbol(_ symbol: UIImage.Symbol, actionHandler: @escaping UIActionHandler) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .tertiarySystemFill
        button.clipsToBounds = true
        button.layer.cornerRadius = 8

        let symbolConfiguration = UIImage.SymbolConfiguration(scale: .large)
        let image = UIImage.fromSymbol(symbol, withConfiguration: symbolConfiguration)
        button.setImage(image.withColor(.label), for: .normal)

        button.addAction(UIAction(handler: actionHandler), for: .touchUpInside)

        return button
    }
}
