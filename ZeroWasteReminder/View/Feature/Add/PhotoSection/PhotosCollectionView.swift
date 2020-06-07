import Combine
import UIKit

public final class PhotosCollectionView: UICollectionView {
    private let viewModel: PhotosCollectionViewModel

    public init(_ viewModel: PhotosCollectionViewModel) {
        self.viewModel = viewModel

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.headerReferenceSize = .init(width: 72, height: .zero)
        layout.minimumLineSpacing = 8

        super.init(frame: .zero, collectionViewLayout: layout)

        self.setupView()
        self.registerCells()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    public override var intrinsicContentSize: CGSize {
        .init(width: super.intrinsicContentSize.width, height: 96)
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        showsHorizontalScrollIndicator = false
        backgroundColor = .systemBackground
        delegate = self
    }

    private func registerCells() {
        register(
            PhotoCell.self,
            forCellWithReuseIdentifier: PhotoCell.identifier
        )

        register(
            PhotoCaptureCell.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: PhotoCaptureCell.identifier
        )
    }
}

extension PhotosCollectionView: UICollectionViewDelegateFlowLayout {
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let sideValue = collectionView.bounds.height
        return .init(width: sideValue, height: sideValue)
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        let deleteAction = UIAction(
            title: .localized(.removePhoto),
            image: .fromSymbol(.trash),
            attributes: .destructive,
            handler: { [weak self] _ in self?.viewModel.setNeedsRemovePhoto(atIndex: indexPath.item) }
        )

        return UIContextMenuConfiguration(identifier: "PhotoContextMenu" as NSCopying, previewProvider: nil) { _ in
            UIMenu(title: "", children: [deleteAction])
        }
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.setNeedsShowPhoto(atIndex: indexPath.item)
    }
}
