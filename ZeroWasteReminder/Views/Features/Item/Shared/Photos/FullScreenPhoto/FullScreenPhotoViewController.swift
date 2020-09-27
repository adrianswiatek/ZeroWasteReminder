import UIKit

public final class FullScreenPhotoViewController: UIViewController {
    public override var prefersStatusBarHidden: Bool {
        true
    }

    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage.fromSymbol(.xmark).withColor(.label), for: .normal)
        button.addTarget(self, action: #selector(handleCloseButtonTap), for: .touchUpInside)
        return button
    }()

    private let buttonBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.layer.cornerRadius = 8
        view.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        return view
    }()

    private let blurVisualEffect: UIView = {
        let effect = UIBlurEffect(style: .systemThinMaterial)
        let view = UIVisualEffectView(effect: effect)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 3
        scrollView.delegate = self
        return scrollView
    }()

    public init(image: UIImage) {
        super.init(nibName: nil, bundle: nil)
        self.imageView.image = image
        self.modalPresentationStyle = .fullScreen
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }

    private func setupView() {
        view.backgroundColor = .systemBackground

        scrollView.addSubview(closeButton)
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.topAnchor, constant: 8),
            closeButton.leadingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.leadingAnchor),
            closeButton.heightAnchor.constraint(equalToConstant: 44),
            closeButton.widthAnchor.constraint(equalToConstant: 44)
        ])

        scrollView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            imageView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            imageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            imageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor)
        ])

        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        scrollView.addSubview(buttonBackgroundView)
        NSLayoutConstraint.activate([
            buttonBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            buttonBackgroundView.trailingAnchor.constraint(equalTo: closeButton.trailingAnchor, constant: 8),
            buttonBackgroundView.heightAnchor.constraint(equalTo: closeButton.heightAnchor),
            buttonBackgroundView.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor)
        ])

        buttonBackgroundView.addSubview(blurVisualEffect)
        NSLayoutConstraint.activate([
            blurVisualEffect.topAnchor.constraint(equalTo: buttonBackgroundView.topAnchor),
            blurVisualEffect.leadingAnchor.constraint(equalTo: buttonBackgroundView.leadingAnchor),
            blurVisualEffect.bottomAnchor.constraint(equalTo: buttonBackgroundView.bottomAnchor),
            blurVisualEffect.trailingAnchor.constraint(equalTo: buttonBackgroundView.trailingAnchor)
        ])

        scrollView.bringSubviewToFront(buttonBackgroundView)
        scrollView.bringSubviewToFront(closeButton)
    }

    @objc
    private func handleCloseButtonTap() {
        dismiss(animated: true)
    }
}

extension FullScreenPhotoViewController: UIScrollViewDelegate {
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }

    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        guard scrollView.zoomScale > 1, let image = imageView.image else {
            scrollView.contentInset = .zero
            return
        }

        let ratioWidth = imageView.frame.width / image.size.width
        let ratioHeight = imageView.frame.height / image.size.height
        let ratio = min(ratioWidth, ratioHeight)

        let newWidth = image.size.width * ratio
        let newHeight = image.size.height * ratio

        let horizontalInset = 0.5 * (newWidth * scrollView.zoomScale > imageView.frame.width
            ? (newWidth - imageView.frame.width)
            : (scrollView.frame.width - scrollView.contentSize.width))

        let verticalInset = 0.5 * (newHeight * scrollView.zoomScale > imageView.frame.height
            ? (newHeight - imageView.frame.height)
            : (scrollView.frame.height - scrollView.contentSize.height))

        scrollView.contentInset =
            .init(top: verticalInset, left: horizontalInset, bottom: verticalInset, right: horizontalInset)
    }
}
