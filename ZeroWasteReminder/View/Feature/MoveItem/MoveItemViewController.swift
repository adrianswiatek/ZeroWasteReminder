import Combine
import UIKit

public final class MoveItemViewController: UIViewController {
    private lazy var dismissButton: UIBarButtonItem =
        .dismissButton(target: self, action: #selector(handleDismiss))

    private lazy var doneButton: UIBarButtonItem =
        .doneButton(target: self, action: #selector(handleDone))

    private let tableView: MoveItemTableView
    private let dataSource: MoveItemDataSource

    private let loadingView: LoadingView

    private let viewModel: MoveItemViewModel
    private var subscriptions: Set<AnyCancellable>

    public init(viewModel: MoveItemViewModel) {
        self.viewModel = viewModel
        self.subscriptions = []

        self.tableView = .init(viewModel)
        self.dataSource = .init(tableView, viewModel)

        self.loadingView = .init()

        super.init(nibName: nil, bundle: nil)

        self.setupView()
        self.setupNavigationItem()
        self.bind()

        self.viewModel.fetchLists()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    private func setupView() {
        view.backgroundColor = .systemBackground

        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        view.addSubview(loadingView)
        NSLayoutConstraint.activate([
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
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

        viewModel.isLoading
            .sink { [weak self] in $0 ? self?.loadingView.show() : self?.loadingView.hide() }
            .store(in: &subscriptions)

        viewModel.requestsSubject
            .sink { [weak self] in self?.handleRequest($0) }
            .store(in: &subscriptions)
    }

    private func handleRequest(_ request: MoveItemViewModel.Request) {
        switch request {
        case .dismiss:
            dismiss(animated: true)
        case .showErrorMessage(let message):
            UIAlertController.presentError(in: self, withMessage: message)
        }
    }

    @objc
    private func handleDismiss() {
        dismiss(animated: true)
    }

    @objc func handleDone() {
        viewModel.moveItem()
    }
}
