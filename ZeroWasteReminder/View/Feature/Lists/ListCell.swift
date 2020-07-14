import Combine
import UIKit

public final class ListCell: UITableViewCell, ReuseIdentifiable {
    private var subscriptions: Set<AnyCancellable>

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
        textLabel?.text = list.name
    }

    private func setupView() {
        backgroundColor = .secondarySystemBackground
        selectedBackgroundView = backgroundView()
    }

    private func backgroundView() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.accent.withAlphaComponent(0.5)
        return view
    }
}
