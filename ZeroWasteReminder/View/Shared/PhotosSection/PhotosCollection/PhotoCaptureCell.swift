import Combine
import UIKit

public final class PhotoCaptureCell: UICollectionViewCell, ReuseIdentifiable {
    public var tap: AnyPublisher<PhotoCaptureTarget, Never> {
        photoCaptureView.tap.eraseToAnyPublisher()
    }

    private let photoCaptureView: PhotoCaptureView
    private var subscription: AnyCancellable?

    public override init(frame: CGRect) {
        photoCaptureView = .init()
        super.init(frame: frame)
        setupView()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    public func set(_ subscription: AnyCancellable) {
        self.subscription = subscription
    }

    private func setupView() {
        contentView.addSubview(photoCaptureView)
        NSLayoutConstraint.activate([
            photoCaptureView.topAnchor.constraint(equalTo: contentView.topAnchor),
            photoCaptureView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            photoCaptureView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            photoCaptureView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
}
