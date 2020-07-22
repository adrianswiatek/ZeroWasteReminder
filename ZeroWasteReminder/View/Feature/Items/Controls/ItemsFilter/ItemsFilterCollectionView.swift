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

        self.setupView()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        collectionViewLayout.invalidateLayout()
    }

    public func scrollToBeginning() {
        DispatchQueue.main.async {
            let indexToScroll = self.viewModel.indexToScroll
            let indexPathToScroll = IndexPath(item: indexToScroll, section: 0)
            self.scrollToItem(at: indexPathToScroll, at: .centeredHorizontally, animated: true)
        }
    }

    private func setupView() {
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
        viewModel.toggleItem(at: indexPath.item)
    }
}

extension ItemsFilterCollectionView: UICollectionViewDelegateFlowLayout {
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        .init(width: .cellWidth, height: .cellHeight)
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        let screenWidth = UIScreen.main.bounds.width

        let numberOfCells = viewModel.totalNumberOfCells
        let itemsTotalWidth = CGFloat(numberOfCells) * .cellWidth + CGFloat(numberOfCells + 1) * .spaceWidth

        if itemsTotalWidth > screenWidth {
            return .init(top: .zero, left: .spaceWidth, bottom: .zero, right: .spaceWidth)
        }

        let sideSpace = (screenWidth - itemsTotalWidth) / 2
        return .init(top: .zero, left: sideSpace, bottom: .zero, right: sideSpace)
    }
}

private extension CGFloat {
    static let cellHeight: CGFloat = 26
    static let cellWidth: CGFloat = 128
    static let spaceWidth: CGFloat = 8
}
