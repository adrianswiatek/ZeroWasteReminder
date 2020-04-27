import UIKit

public final class ItemsFilterCollectionView: UICollectionView {
    private let viewModel: ItemsFilterViewModel

    public init(_ viewModel: ItemsFilterViewModel) {
        self.viewModel = viewModel

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal

        super.init(frame: .zero, collectionViewLayout: layout)

        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .accent
        self.allowsSelection = true
        self.showsHorizontalScrollIndicator = false
        self.delegate = self

        self.register(
            ItemsFilterCollectionViewCell.self,
            forCellWithReuseIdentifier: ItemsFilterCollectionViewCell.identifier
        )
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    public func scrollToBeginning() {
        DispatchQueue.main.async {
            let indexToScroll = self.viewModel.indexToScroll
            self.scrollToItem(at: IndexPath(item: indexToScroll, section: 0), at: .left, animated: true)
        }
    }

    private func itemsFilterCell(at indexPath: IndexPath) -> ItemsFilterCollectionViewCell? {
        cellForItem(at: indexPath) as? ItemsFilterCollectionViewCell
    }
}

extension ItemsFilterCollectionView: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.toggleItem(atIndex: indexPath.item)
    }
}

extension ItemsFilterCollectionView: UICollectionViewDelegateFlowLayout {
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        .init(width: 112, height: 24)
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        .init(top: 0, left: 8, bottom: 0, right: 8)
    }
}
