import UIKit

public final class AlertDataSource: UITableViewDiffableDataSource<AlertDataSource.Section, AlertOption> {
    public init(_ tableView: UITableView, _ viewModel: AlertViewModel) {
        super.init(tableView: tableView, cellProvider: { tableView, indexPath, alertOption in
            let cell = tableView.dequeueReusableCell(withIdentifier: AlertOptionCell.identifier, for: indexPath)

            guard let alertOptionCell = cell as? AlertOptionCell else {
                preconditionFailure("Unable to dequeue AlertOptionCell.")
            }

            alertOptionCell.set(alertOption)
            return alertOptionCell
        })

        self.apply(viewModel.options)
    }

    private func apply(_ options: [AlertOption]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, AlertOption>()
        snapshot.appendSections([.main])
        snapshot.appendItems(options)
        apply(snapshot)
    }
}

extension AlertDataSource {
    public enum Section {
        case main
    }
}
