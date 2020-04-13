import UIKit

public final class ListTableViewCell: UITableViewCell {
    public static let identifier: String = "ListTableViewCell"

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
        textLabel?.textColor = .darkText
        selectedBackgroundView = viewForSelectedCell()
    }

    private func viewForSelectedCell() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.accent.withAlphaComponent(0.5)
        return view
    }
}
