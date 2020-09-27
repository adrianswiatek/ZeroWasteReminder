import UIKit

public final class EmptyListView: UIView {
    private let imageView: UIImageView = {
        let symbolConfiguration = UIImage.SymbolConfiguration(scale: .large)
        let image = UIImage.fromSymbol(.listDash, withConfiguration: symbolConfiguration)
        let imageView = UIImageView(image: image.withColor(.tertiaryLabel))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .tertiaryLabel
        label.textAlignment = .center
        return label
    }()

    private let text: String

    public init(text: String) {
        self.text = text
        super.init(frame: .zero)
        self.setupView()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    private func setupView() {
        label.text = text

        addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 64),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])

        addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            label.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
}
