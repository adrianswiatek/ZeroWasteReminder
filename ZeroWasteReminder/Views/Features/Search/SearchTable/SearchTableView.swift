import Combine
import UIKit

public final class SearchTableView: UITableView {
    public var rowSelected: AnyPublisher<Int, Never> {
        selectedRowSubject.eraseToAnyPublisher()
    }

    private let selectedRowSubject: PassthroughSubject<Int, Never>

    public override init(frame: CGRect, style: UITableView.Style) {
        self.selectedRowSubject = .init()
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

        delegate = self

        register(SearchItemCell.self, forCellReuseIdentifier: SearchItemCell.identifier)
    }
}

extension SearchTableView: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedRowSubject.send(indexPath.row)
    }
}
