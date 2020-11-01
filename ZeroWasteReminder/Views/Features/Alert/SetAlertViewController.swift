import UIKit

public final class AlertViewController: UIViewController {
    private let viewModel: AlertViewModel

    public init(viewModel: AlertViewModel) {

        super.init(nibName: nil, bundle: nil)
        self.setupView()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    private func setupView() {
        view.backgroundColor = .systemBackground

    }
}
