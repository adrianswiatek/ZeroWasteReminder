import UIKit

public final class AlertDataSource: UITableViewDiffableDataSource<AlertDataSource.Section, AlertOption> {
    private let viewModel: AlertViewModel

    public init(_ tableView: UITableView, _ viewModel: AlertViewModel) {
        self.viewModel = viewModel
        super.init(tableView: tableView, cellProvider: { tableView, indexPath, alertOption in
            let cell = tableView.dequeueReusableCell(withIdentifier: AlertOptionCell.identifier, for: indexPath)
            cell.textLabel?.text = alertOption.formatted
            return cell
        })
    }

    private func apply() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, AlertOption>()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModel.options)
        apply(snapshot)
    }
}

extension AlertDataSource {
    public enum Section {
        case main
    }
}
