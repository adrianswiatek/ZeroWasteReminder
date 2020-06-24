import UIKit

public final class ItemsListDelegate: NSObject, UITableViewDelegate {
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

    public func tableView(
        _ tableView: UITableView,
        contextMenuConfigurationForRowAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        let deleteAction = UIAction(
            title: .localized(.removeItem),
            image: .fromSymbol(.trash),
            attributes: .destructive,
            handler: { [weak self] _ in self?.viewModel.setNeedsRemoveItem(at: indexPath.row) }
        )

        return UIContextMenuConfiguration(identifier: "ItemsContextMenu" as NSCopying, previewProvider: nil) { _ in
            UIMenu(title: "", children: [deleteAction])
        }
    }
}
