import Combine
import UIKit

public final class ItemsDataSource: UITableViewDiffableDataSource<ItemsDataSource.Section, Item> {
    private let viewModel: ItemsViewModel
    private var subscriptions: [AnyCancellable]

    public init(_ tableView: UITableView, _ viewModel: ItemsViewModel) {
        self.viewModel = viewModel
        self.subscriptions = []

        super.init(tableView: tableView) { tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ItemCell.identifier,
                for: indexPath
            ) as? ItemCell
            cell?.viewModel = viewModel.cellViewModel(for: item)
            return cell
        }

        self.bind()
    }

    private func bind() {
        viewModel.$items
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

extension ItemsDataSource {
    public enum Section {
        case main
    }
}
