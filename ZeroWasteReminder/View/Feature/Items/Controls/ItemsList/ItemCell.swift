import UIKit

public final class ItemCell: UITableViewCell, ReuseIdentifiable {
    public var viewModel: ItemsCellViewModel! {
        didSet {
            remainingView.viewModel = viewModel.remainingViewModel
            reloadUserInterface()
        }
    }

    public let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.numberOfLines = 0
        return label
    }()

    public let expirationDateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .light)
        label.textColor = .secondaryLabel
        return label
    }()

    public let remainingView = RemainingView()

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

        contentView.addSubview(expirationDateLabel)
        NSLayoutConstraint.activate([
            expirationDateLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            expirationDateLabel.leadingAnchor.constraint(equalTo: remainingView.trailingAnchor, constant: 8),
            expirationDateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            expirationDateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32)
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
    }
}
