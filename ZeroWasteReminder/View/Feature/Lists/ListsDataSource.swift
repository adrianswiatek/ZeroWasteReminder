import Combine
import UIKit

public final class ListsDataSource: UITableViewDiffableDataSource<ListsDataSource.Section, String> {
    private let viewModel: ListsViewModel
    private var subscriptions: Set<AnyCancellable>

    public init(_ tableView: UITableView, _ viewModel: ListsViewModel) {
        self.viewModel = viewModel
        self.subscriptions = []

        super.init(tableView: tableView) { tableView, indexPath, listName in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.backgroundColor = .secondarySystemBackground
            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.text = listName
            return cell
        }

        self.bind()
    }

    public func apply(_ titles: [String]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, String>()
        snapshot.appendSections([.main])
        snapshot.appendItems(titles)
        apply(snapshot)
    }

    private func bind() {

    }
}

extension ListsDataSource {
    public enum Section {
        case main
    }
}
