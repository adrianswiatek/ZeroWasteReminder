import UIKit

public final class SearchItemCell: UITableViewCell {
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        self.setupView()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    public func set(_ searchItem: SearchItem) {
        textLabel?.text = searchItem.item.name
        detailTextLabel?.text = searchItem.list?.name
    }

    private func setupView() {
        accessoryType = .disclosureIndicator
        selectedBackgroundView = backgroundView()
        detailTextLabel?.textColor = .secondaryLabel
    }

    private func backgroundView() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.15)
        return view
    }
}
