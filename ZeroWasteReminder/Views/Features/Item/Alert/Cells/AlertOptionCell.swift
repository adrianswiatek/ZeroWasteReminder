import UIKit

public final class AlertOptionCell: UITableViewCell {
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        self.setupView()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    public func set(_ alertOption: AlertOption) {
        textLabel?.text = alertOption.formatted
    }

    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        textLabel?.textColor = isSelected ? .label : .secondaryLabel
        accessoryType = isSelected ? .checkmark : .none
    }

    public override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)

        backgroundColor = isHighlighted ? .secondarySystemBackground : .clear
    }

    private func setupView() {
        tintColor = .label

        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = .clear
    }
}
