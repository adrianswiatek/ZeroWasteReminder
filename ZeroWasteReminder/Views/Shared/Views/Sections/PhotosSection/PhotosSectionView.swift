import Combine
import UIKit

public final class PhotosSectionView: UIView {
    private let label: UILabel
    private let view: PhotosView

    public init(viewModel: PhotosViewModel) {
        self.label = .defaultWithText(.localized(.photos))
        self.view = PhotosView(viewModel)

        super.init(frame: .zero)

        self.setupView()
    }

    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor)
        ])

        addSubview(view)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: label.bottomAnchor, constant: Metrics.spacing),
            view.leadingAnchor.constraint(equalTo: leadingAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor),
            view.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}

private extension PhotosSectionView {
    enum Metrics {
        static let spacing: CGFloat = 8
    }
}
