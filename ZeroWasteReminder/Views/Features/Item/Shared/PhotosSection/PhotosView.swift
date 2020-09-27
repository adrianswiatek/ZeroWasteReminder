import Combine
import UIKit

public final class PhotosView: UIView {
    private let loadingView: LoadingView
    private let emptyView: PhotosEmptyView

    private let collectionView: PhotosCollectionView
    private let collectionViewDataSource: PhotosDataSource

    private let viewModel: PhotosViewModel

    private var subscriptions: Set<AnyCancellable>

    public init(viewModel: PhotosViewModel) {
        self.viewModel = viewModel

        self.loadingView = .init()
        self.emptyView = .init()

        self.collectionView = .init(viewModel)
        self.collectionViewDataSource = .init(collectionView, viewModel)

        self.subscriptions = []

        super.init(frame: .zero)

        self.setupLoadingView()
        self.setupView()
        self.bind()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    private func setupLoadingView() {
       let loadingViewColor: UIColor = traitCollection.userInterfaceStyle == .dark ? .black : .white
       loadingView.backgroundColor = loadingViewColor.withAlphaComponent(0.75)
       loadingView.layer.cornerRadius = 8
       loadingView.show()
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(emptyView)
        NSLayoutConstraint.activate([
            emptyView.topAnchor.constraint(equalTo: topAnchor),
            emptyView.leadingAnchor.constraint(equalTo: leadingAnchor),
            emptyView.bottomAnchor.constraint(equalTo: bottomAnchor),
            emptyView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        addSubview(loadingView)
        NSLayoutConstraint.activate([
            loadingView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
            loadingView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor)
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
