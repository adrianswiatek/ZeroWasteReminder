import UIKit

public final class LoadingView: UIView {
    private let activityIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var isIndicatorEnabled: Bool

    public override init(frame: CGRect) {
        self.isIndicatorEnabled = true
        super.init(frame: frame)
        self.setupView()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    public func show() {
        if isIndicatorEnabled {
            activityIndicatorView.startAnimating()
        }

        animate(alpha: 1)
        isIndicatorEnabled = true
    }

    public func hide() {
        animate(alpha: 0)
        activityIndicatorView.stopAnimating()
    }

    public func disableLoadingIndicatorOnce() {
        isIndicatorEnabled = false
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor.accent.withAlphaComponent(0.35)
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
