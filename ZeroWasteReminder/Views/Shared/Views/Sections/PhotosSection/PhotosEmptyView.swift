import Combine
import UIKit

public final class PhotosEmptyView: UIView {
    public var tap: AnyPublisher<PhotoCaptureTarget, Never> {
        photoCaptureView.tap.eraseToAnyPublisher()
    }

    private let photoCaptureView: PhotoCaptureView

    private let imageView: UIImageView = configure(.init()) {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.tintColor = .tertiaryLabel

        let symbolConfiguration = UIImage.SymbolConfiguration(scale: .large)
        $0.image = .fromSymbol(.photoOnRectangle, withConfiguration: symbolConfiguration)
    }

    private let label: UILabel = configure(.init()) {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = .localized(.noPhotosToShow)
        $0.textColor = .tertiaryLabel
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: 15)
    }

    private let backgroundView: UIView = configure(.init()) {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.layer.borderColor = UIColor.tertiarySystemFill.cgColor
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 8
    }

    public init() {
        self.photoCaptureView = .init()

        super.init(frame: .zero)

        self.setupView()
    }

    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    public override var intrinsicContentSize: CGSize {
        .init(width: super.intrinsicContentSize.width, height: 96)
    }

    public func setVisibility(_ isVisible: Bool) {
        if let superview = superview {
            UIView.transition(with: superview, duration: 0.3, options: .transitionCrossDissolve, animations: {
                super.isHidden = !isVisible
            })
        } else {
            isHidden = !isVisible
        }
    }

    public func hideActivityIndicators() {
        photoCaptureView.hideActivityIndicators()
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
