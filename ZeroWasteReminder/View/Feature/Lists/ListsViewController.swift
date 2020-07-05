import Combine
import UIKit

public final class ListsViewController: UIViewController {
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    private lazy var collectionView: UICollectionView = {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.headerReferenceSize = .init(width: UIScreen.main.bounds.width, height: 64)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(
            ListCell.self,
            forCellWithReuseIdentifier: ListCell.identifier
        )
        collectionView.register(
            NewListCell.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: NewListCell.identifier
        )
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.refreshControl = UIRefreshControl()
        collectionView.refreshControl?.addTarget(self, action: #selector(handlePullToRefresh), for: .valueChanged)
        return collectionView
    }()

    private lazy var dataSource: ListsDataSource = .init(collectionView, viewModel)

    private let viewModel: ListsViewModel
    private let factory: ViewControllerFactory

    private var subscriptions: Set<AnyCancellable>

    public init(viewModel: ListsViewModel, factory: ViewControllerFactory) {
        self.viewModel = viewModel
        self.factory = factory
        self.subscriptions = []

        super.init(nibName: nil, bundle: nil)

        self.setupView()
        self.bind()

        self.dataSource.apply(["Pantry", "Cosmetics", "Alcohol"])
//        self.dataSource.apply([])
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported")
    }

    private func setupView() {
        view.backgroundColor = .accent
        
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24)
        ])
    }

    private func bind() {
        viewModel.needsOpenList
            .sink { [weak self] in self.map { $0.present($0.factory.listViewController, animated: true) } }
            .store(in: &subscriptions)
    }

    @objc
    private func handlePullToRefresh() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.collectionView.refreshControl?.endRefreshing()
        }
    }
}

extension ListsViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        return .init(width: (screenWidth - (2 * 24)), height: 64)
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        16
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.setNeedsOpenList()
    }
}
