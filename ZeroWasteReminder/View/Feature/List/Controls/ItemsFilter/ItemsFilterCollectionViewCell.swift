import UIKit

public final class ItemsFilterCollectionViewCell: UICollectionViewCell {
    public static let identifier: String = "ItemsFilterCollectionViewCell"

    public var viewModel: ItemsFilterCellViewModel? {
        didSet {
            label.text = viewModel?.title
            viewModel?.isSelected == true ? select() : deselect()
        }
    }

    private var isCellSelected: Bool {
        backgroundColor == .init(white: 1, alpha: 0.15)
    }

    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = .systemFont(ofSize: 13, weight: .light)
        return label
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUserInterface()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    public func toggleSelection() {
        isCellSelected ? deselect() : select()
    }

    private func select() {
        label.font = .systemFont(ofSize: 13, weight: .bold)
        backgroundColor = .init(white: 1, alpha: 0.25)
        layer.borderWidth = 0
    }

    private func deselect() {
        label.font = .systemFont(ofSize: 13, weight: .light)
        backgroundColor = .clear
        layer.borderWidth = 1
    }

    private func setupUserInterface() {
        layer.cornerRadius = 8
        layer.borderColor = UIColor.init(white: 1, alpha: 0.25).cgColor

        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
