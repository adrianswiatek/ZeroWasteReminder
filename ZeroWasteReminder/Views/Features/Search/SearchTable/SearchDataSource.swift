import Combine
import UIKit

public final class SearchDataSource: UITableViewDiffableDataSource<SearchDataSource.Section, SearchItem> {
    private let viewModel: SearchViewModel
    private var subscriptions: Set<AnyCancellable>

    public init(_ tableView: UITableView, _ viewModel: SearchViewModel) {
        self.viewModel = viewModel
        self.subscriptions = []

        super.init(tableView: tableView) { tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(
                withIdentifier: SearchItemCell.identifier,
                for: indexPath
            ) as? SearchItemCell

            cell?.set(item)
            return cell
        }
    }

    public func initialize() {
        viewModel.$items
            .sink { [weak self] in self?.apply($0) }
            .store(in: &subscriptions)
    }

    private func apply(_ items: [SearchItem]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, SearchItem>()
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
