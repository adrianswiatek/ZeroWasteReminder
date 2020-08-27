import Combine
import UIKit

public final class MoveItemDataSource: UITableViewDiffableDataSource<MoveItemDataSource.Section, List> {
    private let viewModel: MoveItemViewModel
    private var subscriptions: Set<AnyCancellable>

    public init(_ tableView: UITableView, _ viewModel: MoveItemViewModel) {
        self.viewModel = viewModel
        self.subscriptions = []

        super.init(tableView: tableView) { tableView, indexPath, list in
            let cell = tableView.dequeueReusableCell(
                withIdentifier: UITableViewCell.identifier,
                for: indexPath
            )

            cell.textLabel?.text = list.name

            let backgroundView = UIView()
            backgroundView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.15)
            backgroundView.layer.cornerRadius = 16
            cell.selectedBackgroundView = backgroundView

            return cell
        }

        self.bind()
    }

    private func bind() {
        viewModel.$lists
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

extension MoveItemDataSource {
    public enum Section {
        case main
    }
}
