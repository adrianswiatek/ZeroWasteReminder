import Combine
import UIKit

public final class MoveItemViewController: UIViewController {
    private lazy var dismissButton: UIBarButtonItem =
        .dismissButton(target: self, action: #selector(handleDismiss))

    private lazy var doneButton: UIBarButtonItem =
        .doneButton(target: self, action: #selector(handleDone))

    private let viewModel: MoveItemViewModel
    private var subscriptions: Set<AnyCancellable>

    public init(viewModel: MoveItemViewModel) {
        self.viewModel = viewModel
        self.subscriptions = []

        super.init(nibName: nil, bundle: nil)

        self.setupView()
        self.setupNavigationItem()
        self.bind()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    private func setupView() {
        view.backgroundColor = .systemBackground
    }

    private func setupNavigationItem() {
        navigationItem.title = .localized(.moveItem)

        navigationItem.leftBarButtonItem = dismissButton
        navigationItem.rightBarButtonItem = doneButton
    }

    private func bind() {
        viewModel.canMoveItem
            .sink { [weak self] in self?.doneButton.isEnabled = $0 }
            .store(in: &subscriptions)
    }

    @objc
    private func handleDismiss() {
        dismiss(animated: true)
    }

    @objc func handleDone() {
        dismiss(animated: true)
    }
}
