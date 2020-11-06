import Combine
import UIKit

public final class ItemsFilterDataSource: UICollectionViewDiffableDataSource<ItemsFilterDataSource.Section,
                                                                             ItemsFilterCellViewModel> {
    private let viewModel: ItemsFilterViewModel
    private let collectionView: UICollectionView
    private var subscriptions: Set<AnyCancellable>

    public init(_ collectionView: UICollectionView, _ viewModel: ItemsFilterViewModel) {
        self.viewModel = viewModel
        self.collectionView = collectionView

        self.subscriptions = []

        super.init(collectionView: collectionView) { collectionView, indexPath, cellViewModel in
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ItemsFilterCollectionViewCell.identifier,
                for: indexPath
            ) as? ItemsFilterCollectionViewCell
            cell?.viewModel = cellViewModel
            return cell
        }

        self.bind()
    }

    private func bind() {
        viewModel.cellViewModels
            .sink { [weak self] in self?.apply($0) }
            .store(in: &subscriptions)
    }

    private func apply(_ items: [ItemsFilterCellViewModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, ItemsFilterCellViewModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items)
        apply(snapshot)
    }
}

extension ItemsFilterDataSource {
    public enum Section {
        case main
    }
}
