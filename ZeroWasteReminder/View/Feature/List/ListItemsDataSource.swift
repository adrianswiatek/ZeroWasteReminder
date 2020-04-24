import Combine
import UIKit

public final class ListItemsDataSource: UITableViewDiffableDataSource<ListItemsDataSource.Section, Item> {
    private let viewModel: ListViewModel
    private var subscriptions: [AnyCancellable]

    public init(_ tableView: UITableView, _ viewModel: ListViewModel) {
        self.viewModel = viewModel
        self.subscriptions = []

        super.init(tableView: tableView) { tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ListTableViewCell.identifier,
                for: indexPath
            ) as? ListTableViewCell
            cell?.viewModel = viewModel.cellViewModel(forItem: item)
            return cell
        }

        self.bind()
    }

    private func bind() {
        viewModel.items
            .sink { [weak self] in self?.apply(items: $0) }
            .store(in: &subscriptions)
    }

    private func apply(items: [Item]) {
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
