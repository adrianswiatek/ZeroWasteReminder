import Combine
import UIKit

public final class SearchDataSource: UITableViewDiffableDataSource<SearchDataSource.Section, Item> {
    private let viewModel: SearchViewModel
    private var subscriptions: Set<AnyCancellable>

    public init(_ tableView: UITableView, _ viewModel: SearchViewModel) {
        self.viewModel = viewModel
        self.subscriptions = []

        super.init(tableView: tableView) { tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(
                withIdentifier: SearchCell.identifier,
                for: indexPath
            ) as? SearchCell

            cell?.set(item)
            return cell
        }

        self.bind()
    }

    private func bind() {
        viewModel.$items
            .sink { [weak self] in self?.apply($0) }
            .store(in: &subscriptions)
    }

    private func apply(_ items: [Item]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items)
        apply(snapshot)
    }
}

extension SearchDataSource {
    public enum Section {
        case main
    }
}
