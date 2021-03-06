import Combine
import UIKit

public final class PhotosDataSource: UICollectionViewDiffableDataSource<PhotosDataSource.Section, UIImage> {
    private let viewModel: PhotosViewModel
    private var subscriptions: Set<AnyCancellable>

    public init(_ collectionView: UICollectionView, _ viewModel: PhotosViewModel) {
        self.viewModel = viewModel
        self.subscriptions = []

        super.init(collectionView: collectionView) { collectionView, indexPath, image in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PhotoCell.identifier,
                for: indexPath
            ) as? PhotoCell else {
                preconditionFailure("Cannot dequeue reusable cell.")
            }

            cell.setPhoto(image)
            return cell
        }

        self.setupSupplementaryViewProvider()
        self.bind()
    }

    private func apply(_ thumbnails: [Photo]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, UIImage>()
        snapshot.appendSections([.main])
        snapshot.appendItems(thumbnails.map { $0.asImage })
        apply(snapshot)
    }

    private func setupSupplementaryViewProvider() {
        supplementaryViewProvider = { [weak self] collectionView, _, indexPath in
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: PhotoCaptureCell.identifier,
                for: indexPath
            ) as? PhotoCaptureCell else {
                preconditionFailure("Cannot dequeue header.")
            }

            let subscription = header.tap.sink {
                self?.viewModel.tryCapturePhoto(target: $0)
            }

            header.set(subscription)
            return header
        }
    }

    private func bind() {
        viewModel.thumbnails
            .sink { [weak self] in self?.apply($0) }
            .store(in: &subscriptions)
    }
}

extension PhotosDataSource {
    public enum Section {
        case main
    }
}
