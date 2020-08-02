import Combine
import UIKit

public final class ListCell: UITableViewCell, ReuseIdentifiable {
    private var subscriptions: Set<AnyCancellable>

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.font = .systemFont(ofSize: 17)
        label.numberOfLines = 0
        return label
    }()

    private let calendarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false

        let image = UIImage.fromSymbol(.calendar)
        imageView.image = image.withColor(.secondaryLabel)

        return imageView
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 14, weight: .light)
        return label
    }()

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.subscriptions = []
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupView()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported")
    }

    public func setList(_ list: List) {
        titleLabel.text = list.name

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dateLabel.text = dateFormatter.string(for: list.updateDate)
    }

    private func setupView() {
        backgroundColor = .systemBackground
        selectedBackgroundView = backgroundView()
        accessoryView = .init(frame: .init(x: 0, y: 0, width: .smallPadding, height: 0))

        contentView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: .bigPadding),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: .bigPadding),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])

        contentView.addSubview(calendarImageView)
        NSLayoutConstraint.activate([
            calendarImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: .smallPadding),
            calendarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: .bigPadding),
            calendarImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -.smallPadding),
        ])

        contentView.addSubview(dateLabel)
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: .smallPadding),
            dateLabel.leadingAnchor.constraint(equalTo: calendarImageView.trailingAnchor, constant: .smallPadding),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -.smallPadding)
        ])
    }

    private func backgroundView() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.accent.withAlphaComponent(0.5)
        return view
    }
}

private extension CGFloat {
    static let bigPadding: CGFloat = 16
    static let smallPadding: CGFloat = 8
}
