import Combine
import UIKit

public final class MoveItemHeaderView: UIView {
    private let itemNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.text = .localized(.itemToMove)
        label.font = .systemFont(ofSize: 14)
        return label
    }()

    private let itemNameValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        return label
    }()

    private let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .secondaryLabel
        return view
    }()

    private let listsNamesLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.text = .localized(.availableLists)
        label.font = .systemFont(ofSize: 14)
        return label
    }()

    private let viewModel: MoveItemViewModel
    private var subscriptions: Set<AnyCancellable>

    public init(_ viewModel: MoveItemViewModel) {
        self.viewModel = viewModel
        self.subscriptions = []
        self.itemNameValueLabel.text = viewModel.itemName

        super.init(frame: .zero)

        self.setupView()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(itemNameLabel)
        NSLayoutConstraint.activate([
            itemNameLabel.topAnchor.constraint(equalTo: topAnchor, constant: Metric.bigPadding),
            itemNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metric.bigPadding),
        ])

        addSubview(itemNameValueLabel)
        NSLayoutConstraint.activate([
            itemNameValueLabel.topAnchor.constraint(equalTo: itemNameLabel.bottomAnchor, constant: Metric.smallPadding),
            itemNameValueLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metric.bigPadding),
            itemNameValueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metric.bigPadding)
        ])

        addSubview(separatorView)
        NSLayoutConstraint.activate([
            separatorView.topAnchor.constraint(equalTo: itemNameValueLabel.bottomAnchor, constant: Metric.bigPadding),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metric.bigPadding),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metric.bigPadding),
            separatorView.heightAnchor.constraint(equalToConstant: 0.5)
        ])

        addSubview(listsNamesLabel)
        NSLayoutConstraint.activate([
            listsNamesLabel.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: Metric.bigPadding),
            listsNamesLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metric.bigPadding),
            listsNamesLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metric.bigPadding),
            listsNamesLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

private extension MoveItemHeaderView {
    enum Metric {
        static let bigPadding: CGFloat = 16
        static let smallPadding: CGFloat = 8
    }
}
