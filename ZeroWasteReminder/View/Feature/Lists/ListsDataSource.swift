import Combine
import UIKit

public final class ListsDataSource: UITableViewDiffableDataSource<ListsDataSource.Section, List> {
    private let viewModel: ListsViewModel
    private var subscriptions: Set<AnyCancellable>

    public init(_ tableView: UITableView, _ viewModel: ListsViewModel) {
        self.viewModel = viewModel
        self.subscriptions = []

        super.init(tableView: tableView) { tableView, indexPath, list in
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ListCell.identifier,
                for: indexPath
            ) as? ListCell

            cell?.setList(list)
            return cell
        }

        self.bind()
    }

    private func bind() {
        viewModel.lists
            .sink { [weak self] in self?.apply($0) }
            .store(in: &subscriptions)
    }

    private func apply(_ lists: [List]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, List>()
        snapshot.appendSections([.main])
        snapshot.appendItems(lists)
        apply(snapshot)
    }
}

extension ListsDataSource {
    public enum Section {
        case main
    }
}
