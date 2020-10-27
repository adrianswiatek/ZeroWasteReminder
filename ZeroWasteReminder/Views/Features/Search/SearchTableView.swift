import UIKit

public final class SearchTableView: UITableView {
    public override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        self.setupView()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor.accent.withAlphaComponent(0.75)
        tableFooterView = UIView()
    }
}

extension SearchTableView: UITableViewDelegate {

}
