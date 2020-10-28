import UIKit

public final class SearchCell: UITableViewCell {
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        self.setupView()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    public func set(_ item: Item) {
        textLabel?.text = item.name
        detailTextLabel?.text = item.listId.asString
    }

    private func setupView() {
        accessoryType = .disclosureIndicator
    }
}
