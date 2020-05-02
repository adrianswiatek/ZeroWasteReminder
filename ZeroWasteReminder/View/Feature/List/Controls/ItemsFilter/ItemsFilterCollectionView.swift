import UIKit

public final class ItemsFilterCollectionView: UICollectionView {
    public override var isHidden: Bool {
        get { super.isHidden }
        set { makeTransition(to: newValue) }
    }

    private let viewModel: ItemsFilterViewModel

    public init(_ viewModel: ItemsFilterViewModel) {
        self.viewModel = viewModel

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal

        super.init(frame: .zero, collectionViewLayout: layout)

        self.setupUserInterface()
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

    private func setupUserInterface() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .accent
        allowsSelection = true
        showsHorizontalScrollIndicator = false

        delegate = self

        let cellIdentifier = ItemsFilterCollectionViewCell.identifier
        register(ItemsFilterCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
    }

    private func itemsFilterCell(at indexPath: IndexPath) -> ItemsFilterCollectionViewCell? {
        cellForItem(at: indexPath) as? ItemsFilterCollectionViewCell
    }

    private func makeTransition(to isHidden: Bool) {
        guard let superview = superview else {
            super.isHidden = isHidden
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(isHidden ? 0 : 250)) {
            UIView.transition(with: superview, duration: 0.25, options: .transitionCrossDissolve, animations: {
                super.isHidden = isHidden
            })
        }
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
        .init(width: 128, height: 26)
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        .init(top: 0, left: 8, bottom: 0, right: 8)
    }
}
