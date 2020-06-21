import UIKit

public final class PhotoCell: UICollectionViewCell, ReuseIdentifiable {
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private let loadingView: LoadingView = {
        let view = LoadingView()
        view.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.5)
        return view
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    private func setupView() {
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 8

        contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])

        contentView.addSubview(loadingView)
        NSLayoutConstraint.activate([
            loadingView.topAnchor.constraint(equalTo: contentView.topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            loadingView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }

    public func setPhoto(_ photo: UIImage) {
        imageView.image = photo
    }

    public func showActivityIndicator() {
        loadingView.show()
    }

    public func hideActivityIndicator() {
        loadingView.hide()
    }
}
