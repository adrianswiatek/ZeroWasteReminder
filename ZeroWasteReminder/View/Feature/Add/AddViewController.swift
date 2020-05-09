import Combine
import UIKit

public final class AddViewController: UIViewController {
    private lazy var dismissButton: UIBarButtonItem =
        .dismissButton(target: self, action: #selector(handleDismiss))

    private lazy var doneButton: UIBarButtonItem =
        .doneButton(target: self, action: #selector(handleConfirm))

    private let scrollView: UIScrollView
    private let contentViewController: UIViewController

    private let viewModel: AddViewModel
    private var subscriptions: Set<AnyCancellable>

    public init(viewModel: AddViewModel) {
        self.viewModel = viewModel
        self.subscriptions = []

        self.contentViewController = AddContentViewController(viewModel: viewModel)
        self.scrollView = AdaptiveScrollView()

        super.init(nibName: nil, bundle: nil)

        self.setupNavigationBar()
        self.setupView()
        self.bind()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    private func setupNavigationBar() {
        title = "Add item"

        navigationItem.leftBarButtonItem = dismissButton
        navigationItem.rightBarButtonItem = doneButton
    }

    private func setupView() {
        view.backgroundColor = .systemBackground

        let contentView: UIView = contentViewController.view
        scrollView.addSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 24),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 32),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -12),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -32),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -64)
        ])

        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func bind() {
        viewModel.canSaveItem
            .sink { [weak self] in self?.doneButton.isEnabled = $0 }
            .store(in: &subscriptions)
    }

    @objc
    private func handleDismiss() {
        dismiss(animated: true)
    }

    @objc
    private func handleConfirm() {
        viewModel.saveItem()
            .sink { [weak self] _ in self?.dismiss(animated: true) }
            .store(in: &subscriptions)
    }
}
