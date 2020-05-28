import Combine
import UIKit

public final class PhotosCollectionView: UICollectionView {
    private let viewModel: AddViewModel
    private var subscriptions: Set<AnyCancellable>

    public init(viewModel: AddViewModel) {
        self.viewModel = viewModel
        self.subscriptions = []

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
}
