import UIKit

public final class LoadingView: UIView {
    private let activityIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.translatesAutoresizingMaskIntoConstraints = false
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

    public func show(withLoadingIndicator: Bool = true) {
        if withLoadingIndicator {
            activityIndicatorView.startAnimating()
        }
        animate(alpha: 1)
    }

    public func hide() {
        animate(alpha: 0)
        activityIndicatorView.stopAnimating()
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor.black.withAlphaComponent(0.25)
        alpha = 0

        addSubview(activityIndicatorView)
        NSLayoutConstraint.activate([
            activityIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    private func animate(alpha: CGFloat) {
        UIView.animate(withDuration: 0.3) { self.alpha = alpha }
    }
}
