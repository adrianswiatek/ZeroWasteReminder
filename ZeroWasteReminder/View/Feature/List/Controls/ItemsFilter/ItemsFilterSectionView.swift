import UIKit

public final class ItemsFilterSectionView: UIView {
    private let itemsFilterCollectionView: ItemsFilterCollectionView
    private let itemsFilterDataSource: ItemsFilterDataSource

    private let viewModel: ItemsFilterViewModel

    init(_ viewModel: ItemsFilterViewModel) {
        self.viewModel = viewModel

        self.itemsFilterCollectionView = .init(viewModel)
        self.itemsFilterDataSource = .init(itemsFilterCollectionView, viewModel)

        super.init(frame: .zero)

        self.setupUserInterface()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    public func reset() {
        itemsFilterCollectionView.scrollToBeginning()
    }

    private func setupUserInterface() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .accent

        addSubview(itemsFilterCollectionView)
        NSLayoutConstraint.activate([
            itemsFilterCollectionView.topAnchor.constraint(equalTo: topAnchor),
            itemsFilterCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            itemsFilterCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            itemsFilterCollectionView.heightAnchor.constraint(equalToConstant: 36)
        ])
    }
}
