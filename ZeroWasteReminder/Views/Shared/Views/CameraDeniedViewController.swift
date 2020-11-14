import UIKit

public final class CameraDeniedViewController: UIViewController {
    private lazy var backButton: UIButton = configure(.init(type: .system)) {
        $0.translatesAutoresizingMaskIntoConstraints = false

        let image = UIImage.fromSymbol(.xmark).withColor(.label)
        $0.setImage(image, for: .normal)

        let action = UIAction { [weak self] _ in self?.dismiss(animated: true) }
        $0.addAction(action, for: .touchUpInside)
    }

    private let cameraIcon: UIImageView = configure(.init()) {
        $0.translatesAutoresizingMaskIntoConstraints = false

        let symbolConfiguration = UIImage.SymbolConfiguration(scale: .large)
        $0.image = UIImage.fromSymbol(.cameraFill, withConfiguration: symbolConfiguration).withColor(.label)
    }

    private let titleLabel: UILabel = configure(.init()) {
        $0.textColor = .label
        $0.text = .localized(.youHaveDeniedAccessToTheCamera)
        $0.font = .preferredFont(forTextStyle: .title2)
        $0.numberOfLines = 0
    }

    private let messageLabel: UILabel = configure(.init()) {
        $0.textColor = .label
        $0.text = .localized(.grantAccessToTheCamera)
        $0.font = .preferredFont(forTextStyle: .body)
        $0.numberOfLines = 0
    }

    private let stackView: UIStackView = configure(.init()) {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.spacing = Metrics.componentsSpacing
        $0.axis = .vertical
        $0.alignment = .center
    }

    public init() {
        super.init(nibName: nil, bundle: nil)
        self.setupView()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    private func setupView() {
        view.backgroundColor = .black

        stackView.addArrangedSubview(cameraIcon)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(messageLabel)

        view.addSubview(backButton)
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: Metrics.backButtonPadding
            ),
            backButton.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: Metrics.backButtonPadding
            ),
            backButton.heightAnchor.constraint(equalToConstant: Metrics.backButtonSide),
            backButton.widthAnchor.constraint(equalToConstant: Metrics.backButtonSide)
        ])

        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

private extension CameraDeniedViewController {
    enum Metrics {
        static let backButtonPadding: CGFloat = 8
        static let backButtonSide: CGFloat = 44
        static let componentsSpacing: CGFloat = 16
    }
}
