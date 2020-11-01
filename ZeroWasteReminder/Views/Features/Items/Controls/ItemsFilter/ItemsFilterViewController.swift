import Combine
import UIKit

public final class ItemsFilterViewController: UIViewController {
    public var isShown: Bool {
        heightConstraints?.constant != Metrics.hiddenHeight
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
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }

    public func setVisibility(_ isVisible: Bool) {
        heightConstraints?.constant = isVisible ? Metrics.shownHeight : Metrics.hiddenHeight
        itemsFilterCollectionView.isHidden = !isVisible
    }

    public func reset() {
        itemsFilterCollectionView.scrollToBeginning()
    }

    private func setupView() {
        view.translatesAutoresizingMaskIntoConstraints = false
        itemsFilterCollectionView.isHidden = true
        view.backgroundColor = .accent

        view.layer.cornerRadius = 8
        view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = .init(width: 0, height: 2)

        view.addSubview(itemsFilterCollectionView)
        NSLayoutConstraint.activate([
            itemsFilterCollectionView.topAnchor.constraint(equalTo: view.topAnchor),
            itemsFilterCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            itemsFilterCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            itemsFilterCollectionView.heightAnchor.constraint(equalToConstant: 40)
        ])

        heightConstraints = view.heightAnchor.constraint(equalToConstant: Metrics.hiddenHeight)
        heightConstraints?.isActive = true
    }
}

private extension ItemsFilterViewController {
    enum Metrics {
        static let hiddenHeight: CGFloat = 20
        static let shownHeight: CGFloat = 48
    }
}
