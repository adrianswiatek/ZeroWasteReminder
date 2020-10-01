import UIKit

public final class AlertOptionCell: UITableViewCell {
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupView()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    public func set(_ alertOption: AlertOption) {
        self.textLabel?.text = alertOption.formatted
    }

    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.textLabel?.textColor = self.isSelected ? .label : .secondaryLabel
        self.accessoryType = self.isSelected ? .checkmark : .none
    }

    public override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        self.backgroundColor = self.isHighlighted ? .secondarySystemBackground : .systemBackground
    }

    private func setupView() {
        tintColor = .label
        selectedBackgroundView = configure(UIView()) { $0.backgroundColor = .clear }
    }
}
