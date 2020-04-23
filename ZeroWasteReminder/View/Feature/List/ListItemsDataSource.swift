import UIKit

public final class ListItemsDataSource: UITableViewDiffableDataSource<ListItemsDataSource.Section, Item> {
    public init(_ tableView: UITableView, _ viewModel: ListViewModel) {
        super.init(tableView: tableView) { tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ListTableViewCell.identifier,
                for: indexPath
            ) as? ListTableViewCell
            cell?.viewModel = viewModel.cellViewModel(forItem: item)
            return cell
        }
    }

    public func apply(items: [Item]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items)
        apply(snapshot)
    }

    public override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        tableView.isEditing
    }
}

extension ListItemsDataSource {
    public enum Section {
        case main
    }
}
