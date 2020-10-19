import UIKit

public final class ItemCell: UITableViewCell {
    public var viewModel: ItemsCellViewModel! {
        didSet {
            remainingView.viewModel = viewModel.remainingViewModel
            reloadUserInterface()
        }
    }

    private let nameLabel: UILabel = configure(UILabel()) {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = .label
        $0.font = .systemFont(ofSize: 16, weight: .medium)
        $0.numberOfLines = 0
    }

    private let expirationDateLabel: UILabel = configure(UILabel()) {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .systemFont(ofSize: 14, weight: .light)
        $0.textColor = .secondaryLabel
    }

    private lazy var noteImageView: UIImageView = iconImageView(.squareAndPencil)
    private lazy var alertImageView: UIImageView = iconImageView(.alarm)

    private lazy var secondRowStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [expirationDateLabel, noteImageView, alertImageView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 8
        return stackView
    }()

    private let remainingView = RemainingView()

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: nil)
        self.setupView()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    private func setupView() {
        backgroundColor = .systemBackground
        tintColor = .accent
        accessoryType = .disclosureIndicator
        textLabel?.textColor = .darkText
        selectedBackgroundView = viewForSelectedCell()

        contentView.addSubview(remainingView)
        NSLayoutConstraint.activate([
            remainingView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            remainingView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            remainingView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            remainingView.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
            remainingView.widthAnchor.constraint(equalToConstant: 68)
        ])

        contentView.addSubview(nameLabel)
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            nameLabel.leadingAnchor.constraint(equalTo: remainingView.trailingAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32)
        ])

        contentView.addSubview(secondRowStackView)
        NSLayoutConstraint.activate([
            secondRowStackView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            secondRowStackView.leadingAnchor.constraint(equalTo: remainingView.trailingAnchor, constant: 8),
            secondRowStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            secondRowStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }

    private func viewForSelectedCell() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.15)
        return view
    }

    private func reloadUserInterface() {
        nameLabel.text = viewModel.itemName
        expirationDateLabel.text = viewModel.expirationDate
        noteImageView.isHidden = !viewModel.hasNotes
        alertImageView.isHidden = !viewModel.hasAlert
    }
}

private extension ItemCell {
    func iconImageView(_ symbol: UIImage.Symbol) -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.setContentHuggingPriority(.defaultLow + 1, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.defaultHigh + 1, for: .horizontal)
        imageView.isHidden = true

        let symbolConfiguration = UIImage.SymbolConfiguration(scale: .small)
        let image = UIImage.fromSymbol(symbol, withConfiguration: symbolConfiguration)
        imageView.image = image.withColor(.secondaryLabel)

        return imageView
    }
}
