import Combine
import UIKit

public final class ListsDataSource: UICollectionViewDiffableDataSource<ListsDataSource.Section, String> {
    private let viewModel: ListsViewModel
    private var subscriptions: Set<AnyCancellable>

    public init(_ collectionView: UICollectionView, _ viewModel: ListsViewModel) {
        self.viewModel = viewModel
        self.subscriptions = []

        super.init(collectionView: collectionView) { cell, indexPath, listName in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ListCell.identifier,
                for: indexPath
            ) as? ListCell else {
                preconditionFailure("Cannot dequeue reusable cell.")
            }

            cell.setListName(listName)
            return cell
        }

        self.setupSupplementaryViewProvider()
        self.bind()
    }

    public func apply(_ titles: [String]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, String>()
        snapshot.appendSections([.main])
        snapshot.appendItems(titles)
        apply(snapshot)
    }

    private func setupSupplementaryViewProvider() {
        supplementaryViewProvider = { collectionView, _, indexPath in
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: NewListCell.identifier,
                for: indexPath
            ) as? NewListCell else {
                preconditionFailure("Cannot dequeue header.")
            }

            let subscription = header.tap.sink { [weak self] in
                self?.viewModel.createList()
            }

            header.set(subscription)
            return header
        }
    }

    private func bind() {

    }
}

extension ListsDataSource {
    public enum Section {
        case main
    }
}
