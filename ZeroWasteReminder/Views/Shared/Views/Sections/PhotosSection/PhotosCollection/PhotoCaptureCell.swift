import Combine
import UIKit

public final class PhotoCaptureCell: UICollectionViewCell, ReuseIdentifiable {
    public var tap: AnyPublisher<PhotoCaptureTarget, Never> {
        photoCaptureView.tap.eraseToAnyPublisher()
    }

    private let photoCaptureView: PhotoCaptureView
    private var subscription: AnyCancellable?

    public override init(frame: CGRect) {
        self.photoCaptureView = .init()
        super.init(frame: frame)
        self.setupView()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    public func set(_ subscription: AnyCancellable) {
        self.subscription = subscription
    }

    public func hideActivityIndicators() {
        photoCaptureView.hideActivityIndicators()
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
