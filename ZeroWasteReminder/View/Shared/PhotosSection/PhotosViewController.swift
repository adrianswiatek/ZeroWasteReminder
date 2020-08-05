import Combine
import UIKit

public final class PhotosViewController: UIViewController {
    private let loadingView: LoadingView = {
        let view = LoadingView()
        let loadingViewColor: UIColor = view.traitCollection.userInterfaceStyle == .dark ? .black : .white
        view.backgroundColor = loadingViewColor.withAlphaComponent(0.75)
        view.layer.cornerRadius = 8
        view.show()
        return view
    }()

    private let emptyView: PhotosEmptyView

    private let collectionView: PhotosCollectionView
    private let collectionViewDataSource: PhotosDataSource

    private let viewModel: PhotosViewModel

    private var subscriptions: Set<AnyCancellable>

    public init(viewModel: PhotosViewModel) {
        self.viewModel = viewModel

        self.emptyView = .init()

        self.collectionView = .init(viewModel)
        self.collectionViewDataSource = .init(collectionView, viewModel)

        self.subscriptions = []

        super.init(nibName: nil, bundle: nil)

        self.setupView()
        self.bind()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    private func setupView() {
        view.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(emptyView)
        NSLayoutConstraint.activate([
            emptyView.topAnchor.constraint(equalTo: view.topAnchor),
            emptyView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            emptyView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        view.addSubview(loadingView)
        NSLayoutConstraint.activate([
            loadingView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor)
        ])
    }

    private func bind() {
        emptyView.tap
            .sink { [weak self] in self?.viewModel.requestSubject.send(.capturePhoto(target: $0)) }
            .store(in: &subscriptions)

        viewModel.thumbnails
            .map { $0.isEmpty }
            .sink { [weak self] in self?.setVisibility(hasPhotos: !$0) }
            .store(in: &subscriptions)

        viewModel.isLoadingOverlayVisible
            .sink { [weak self] in $0 ? self?.loadingView.show() : self?.loadingView.hide() }
            .store(in: &subscriptions)
    }

    private func setVisibility(hasPhotos: Bool) {
        collectionView.setVisibility(hasPhotos)
        emptyView.setVisibility(!hasPhotos)
    }
}
