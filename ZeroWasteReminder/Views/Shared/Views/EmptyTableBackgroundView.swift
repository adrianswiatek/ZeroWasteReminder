import UIKit

public final class EmptyTableBackgroundView: UIView {
    private let imageView: UIImageView = configure(.init()) {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    private let label: UILabel = configure(UILabel()) {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = .tertiaryLabel
        $0.textAlignment = .center
    }

    private let text: String
    private let symbol: UIImage.Symbol

    public init(text: String, symbol: UIImage.Symbol = .listDash) {
        self.text = text
        self.symbol = symbol

        super.init(frame: .zero)

        self.setupView()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    private func setupView() {
        label.text = text
        imageView.image = image()

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

    private func image() -> UIImage {
        let symbolConfiguration = UIImage.SymbolConfiguration(scale: .large)
        let image = UIImage.fromSymbol(symbol, withConfiguration: symbolConfiguration)
        return image.withColor(.tertiaryLabel)
    }
}
