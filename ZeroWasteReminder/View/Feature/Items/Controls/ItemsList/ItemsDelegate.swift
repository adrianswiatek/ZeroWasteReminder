import UIKit

public final class ItemsDelegate: NSObject, UITableViewDelegate {
    private let viewModel: ItemsViewModel

    init(_ viewModel: ItemsViewModel) {
        self.viewModel = viewModel
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let itemsTableView = tableView as? ItemsTableView else { return }

        viewModel.selectedItemIndices = itemsTableView.selectedIndices()

        if !tableView.isEditing {
            tableView.deselectRow(at: indexPath, animated: true)
            viewModel.selectItem(at: indexPath.row)
        }
    }

    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let itemsTableView = tableView as? ItemsTableView else { return }
        viewModel.selectedItemIndices = itemsTableView.selectedIndices()
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
