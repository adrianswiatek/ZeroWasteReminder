import UIKit

public final class ListTableViewCell: UITableViewCell {
    public static let identifier: String = "ListTableViewCell"
    public static let height: CGFloat = 56

    public var viewModel: ListTableViewCellViewModel! {
        didSet {
            nameLabel.text = viewModel?.itemName
            expirationDateLabel.text = viewModel?.expirationDate
        }
    }

    public let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()

    public let expirationDateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .light)
        label.textColor = .gray
        return label
    }()

    public let remainingView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .accent
        view.layer.cornerRadius = 8
        return view
    }()

    private let remainingLabel1: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "more than"
        label.textColor = .white
        label.font = .systemFont(ofSize: 14, weight: .thin)
        return label
    }()

    private let remainingLabel2: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "1 year"
        label.textColor = .white
        label.font = .systemFont(ofSize: 15)
        return label
    }()

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: nil)
        self.setupUserInterface()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    private func setupUserInterface() {
        backgroundColor = .clear
        accessoryType = .disclosureIndicator
        textLabel?.textColor = .darkText
        selectedBackgroundView = viewForSelectedCell()

        contentView.addSubview(remainingView)
        NSLayoutConstraint.activate([
            remainingView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            remainingView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            remainingView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            remainingView.heightAnchor.constraint(equalToConstant: 44),
            remainingView.widthAnchor.constraint(equalToConstant: 72)
        ])

        let remainingStackView = UIStackView(arrangedSubviews: [remainingLabel1, remainingLabel2])
        remainingStackView.translatesAutoresizingMaskIntoConstraints = false
        remainingStackView.axis = .vertical
        remainingStackView.alignment = .center

        remainingView.addSubview(remainingStackView)
        NSLayoutConstraint.activate([
            remainingStackView.centerXAnchor.constraint(equalTo: remainingView.centerXAnchor),
            remainingStackView.centerYAnchor.constraint(equalTo: remainingView.centerYAnchor)
        ])

        contentView.addSubview(nameLabel)
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: remainingView.topAnchor, constant: 4),
            nameLabel.leadingAnchor.constraint(equalTo: remainingView.trailingAnchor, constant: 16)
        ])

        contentView.addSubview(expirationDateLabel)
        NSLayoutConstraint.activate([
            expirationDateLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            expirationDateLabel.leadingAnchor.constraint(equalTo: remainingView.trailingAnchor, constant: 16),
            expirationDateLabel.bottomAnchor.constraint(equalTo: remainingView.bottomAnchor, constant: -2)
        ])
    }

    private func viewForSelectedCell() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.15)
        return view
    }
}
