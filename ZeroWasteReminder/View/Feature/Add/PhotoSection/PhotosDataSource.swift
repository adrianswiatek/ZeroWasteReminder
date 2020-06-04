import Combine
import UIKit

public final class PhotosDataSource: UICollectionViewDiffableDataSource<PhotosDataSource.Section, UIImage> {
    private let collectionView: UICollectionView
    private let handler: PhotosCollectionHandler
    private var subscriptions: Set<AnyCancellable>

    public init(_ collectionView: UICollectionView, _ handler: PhotosCollectionHandler) {
        self.collectionView = collectionView
        self.handler = handler
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

    private func setupSupplementaryViewProvider() {
        supplementaryViewProvider = { collectionView, kind, indexPath in
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: PhotoCaptureCell.identifier,
                for: indexPath
            ) as? PhotoCaptureCell else {
                preconditionFailure("Cannot dequeue header.")
            }

            header.cancellable = header.tap.sink { [weak self] in self?.handler.setNeedsCapturePhoto() }
            return header
        }
    }

    private func bind() {
        handler.photos
            .sink { [weak self] in self?.apply($0) }
            .store(in: &subscriptions)
    }

    public func apply(_ images: [UIImage]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, UIImage>()
        snapshot.appendSections([.main])
        snapshot.appendItems(images)
        apply(snapshot)
    }
}

extension PhotosDataSource {
    public enum Section {
        case main
    }
}
