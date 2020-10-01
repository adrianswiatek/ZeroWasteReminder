import Combine
import UIKit

public final class AlertTableView: UITableView {
    private let viewModel: AlertViewModel
    private var subscriptions: Set<AnyCancellable>

    public init(_ viewModel: AlertViewModel) {
        self.viewModel = viewModel
        self.subscriptions = []

        super.init(frame: .zero, style: .plain)

        self.setupView()
        self.registerCells()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .systemBackground
        tableFooterView = UIView()

        delegate = self
    }

    private func registerCells() {
        register(AlertOptionCell.self, forCellReuseIdentifier: AlertOptionCell.identifier)
    }
}

extension AlertTableView: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectOption(at: indexPath.row)
        tableView.cellForRow(at: indexPath).map { $0.setSelected(true, animated: true) }
    }
}
