import Combine
import UIKit

public final class PhotosDataSource: UICollectionViewDiffableDataSource<PhotosDataSource.Section, UIImage> {
    private let viewModel: PhotosCollectionViewModel
    private var subscriptions: Set<AnyCancellable>

    public init(_ collectionView: UICollectionView, _ viewModel: PhotosCollectionViewModel) {
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

    private func setupSupplementaryViewProvider() {
        supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: PhotoCaptureCell.identifier,
                for: indexPath
            ) as? PhotoCaptureCell else {
                preconditionFailure("Cannot dequeue header.")
            }

            header.cancellable = header.tap.sink { self?.viewModel.setNeedsCaptureImage() }
            return header
        }
    }

    private func bind() {
        viewModel.photos
            .sink { [weak self] in self?.apply($0.map { $0.asImage() }) }
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
