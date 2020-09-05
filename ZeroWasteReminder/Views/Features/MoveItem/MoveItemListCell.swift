import UIKit

public final class MoveItemListCell: UITableViewCell {
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupView()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    public func set(_ list: List) {
        textLabel?.text = list.name
    }

    private func setupView() {
        selectedBackgroundView = backgroundView()
    }

    private func backgroundView() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.15)
        view.layer.cornerRadius = 16
        return view
    }
}
