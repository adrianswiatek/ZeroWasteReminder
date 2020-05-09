import UIKit

public final class ItemsListDelegates: NSObject, UITableViewDelegate {
    private let viewModel: ItemsListViewModel

    init(_ viewModel: ItemsListViewModel) {
        self.viewModel = viewModel
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let itemsListTableView = tableView as? ItemsListTableView else { return }

        viewModel.selectedItemIndices = itemsListTableView.selectedIndices()

        if !tableView.isEditing {
            tableView.deselectRow(at: indexPath, animated: true)
            viewModel.selectItem(at: indexPath.row)
        }
    }

    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let itemsListTableView = tableView as? ItemsListTableView else { return }
        viewModel.selectedItemIndices = itemsListTableView.selectedIndices()
    }
}
