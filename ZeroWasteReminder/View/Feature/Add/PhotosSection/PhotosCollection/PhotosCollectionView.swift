import Combine
import UIKit

public final class PhotosCollectionView: UICollectionView {
    private let loadingView: LoadingView = {
        let view = LoadingView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.15)
        view.layer.cornerRadius = 8
        return view
    }()

    private let viewModel: PhotosViewModel
    private var subscriptions: Set<AnyCancellable>

    public init(_ viewModel: PhotosViewModel) {
        self.viewModel = viewModel
        self.subscriptions = []

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.headerReferenceSize = .init(width: 72, height: .zero)
        layout.minimumLineSpacing = 8

        super.init(frame: .zero, collectionViewLayout: layout)

        self.setupView()
        self.registerCells()
        self.bind()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    public override var intrinsicContentSize: CGSize {
        .init(width: super.intrinsicContentSize.width, height: 96)
    }

    public func setVisibility(_ isVisible: Bool) {
        isHidden = !isVisible
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        showsHorizontalScrollIndicator = false
        backgroundColor = .clear
        delegate = self
        loadingView.show()

        addSubview(loadingView)
        NSLayoutConstraint.activate([
            loadingView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor, constant: -8),
            loadingView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor, constant: -8),
            loadingView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor, constant: 8),
            loadingView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor, constant: 8)
        ])
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

    private func bind() {
        viewModel.isLoadingOverlayVisible
            .sink { [weak self] in $0 ? self?.loadingView.show() : self?.loadingView.hide() }
            .store(in: &subscriptions)

        viewModel.needsShowImage
            .sink { [weak self] _ in
                self?.visibleCells.compactMap { $0 as? PhotoCell }.forEach { $0.hideActivityIndicator() }
            }
            .store(in: &subscriptions)
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
            handler: { [weak self] _ in self?.viewModel.setNeedsRemoveImage(at: indexPath.item) }
        )

        return UIContextMenuConfiguration(identifier: "PhotoContextMenu" as NSCopying, previewProvider: nil) { _ in
            UIMenu(title: "", children: [deleteAction])
        }
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        cellForItem(at: indexPath).flatMap { $0 as? PhotoCell }.map { $0.showActivityIndicator() }
        viewModel.setNeedsShowImage(at: indexPath.item)
    }
}

extension PhotosCollectionView: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    public func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        if let imageUrl = info[.imageURL] as? URL {
            viewModel.addImage(at: imageUrl)
        } else if let photo = info[.originalImage] as? UIImage {
            viewModel.addImage(photo)
        }

        picker.dismiss(animated: true)
    }
}
