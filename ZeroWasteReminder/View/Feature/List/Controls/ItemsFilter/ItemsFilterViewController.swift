import Combine
import UIKit

public final class ItemsFilterViewController: UIViewController {
    public var isShown: Bool {
        heightConstraints?.constant != Height.hidden
    }

    private let itemsFilterCollectionView: ItemsFilterCollectionView
    private let itemsFilterDataSource: ItemsFilterDataSource

    private var heightConstraints: NSLayoutConstraint?

    private let viewModel: ItemsFilterViewModel

    init(_ viewModel: ItemsFilterViewModel) {
        self.viewModel = viewModel

        self.itemsFilterCollectionView = .init(viewModel)
        self.itemsFilterDataSource = .init(itemsFilterCollectionView, viewModel)

        super.init(nibName: nil, bundle: nil)

        self.setupUserInterface()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    public func setVisibility(_ isVisible: Bool) {
        heightConstraints?.constant = isVisible ? Height.shown : Height.hidden
        itemsFilterCollectionView.isHidden = !isVisible
    }

    public func reset() {
        itemsFilterCollectionView.scrollToBeginning()
    }

    private func setupUserInterface() {
        view.translatesAutoresizingMaskIntoConstraints = false
        itemsFilterCollectionView.isHidden = true
        view.backgroundColor = .accent

        view.layer.cornerRadius = 12
        view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        view.layer.shadowOpacity = 0.5
        view.layer.shadowOffset = .init(width: 0, height: 2)

        view.addSubview(itemsFilterCollectionView)
        NSLayoutConstraint.activate([
            itemsFilterCollectionView.topAnchor.constraint(equalTo: view.topAnchor),
            itemsFilterCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            itemsFilterCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            itemsFilterCollectionView.heightAnchor.constraint(equalToConstant: 40)
        ])

        heightConstraints = view.heightAnchor.constraint(equalToConstant: Height.hidden)
        heightConstraints?.isActive = true
    }
}

private extension ItemsFilterViewController {
    struct Height {
        static let hidden: CGFloat = 20
        static let shown: CGFloat = 48
    }
}
