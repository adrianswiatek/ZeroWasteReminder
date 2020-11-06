import Combine
import UIKit

public final class MoveItemViewController: UIViewController {
    private lazy var dismissButton: UIBarButtonItem =
        .dismissButton { [weak self] in self?.dismiss(animated: true) }

    private lazy var doneButton: UIBarButtonItem =
        .doneButton { [weak self] in self?.viewModel.moveItem() }

    private let loadingView: LoadingView
    private let warningBarView: WarningBarView
    private let headerView: MoveItemHeaderView

    private let tableView: MoveItemTableView
    private let dataSource: MoveItemDataSource

    private let viewModel: MoveItemViewModel
    private var subscriptions: Set<AnyCancellable>

    public init(viewModel: MoveItemViewModel) {
        self.viewModel = viewModel
        self.subscriptions = []

        self.loadingView = .init()
        self.warningBarView = .init()
        self.headerView = .init(viewModel)

        self.tableView = .init(viewModel)
        self.dataSource = .init(tableView, viewModel)

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

        view.addSubview(warningBarView)
        NSLayoutConstraint.activate([
            warningBarView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            warningBarView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -.smallPadding),
            warningBarView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor)
        ])

        view.addSubview(headerView)
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: .bigPadding
            ),
            headerView.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -.bigPadding
            )
        ])

        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            tableView.bottomAnchor.constraint(
                equalTo: warningBarView.topAnchor, constant: -.bigPadding
            ),
            tableView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor)
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

        viewModel.canRemotelyConnect
            .sink { [weak self] in self?.warningBarView.setVisibility(!$0) }
            .store(in: &subscriptions)
    }

    private func handleRequest(_ request: MoveItemViewModel.Request) {
        switch request {
        case .disableLoadingIndicatorOnce:
            loadingView.disableLoadingIndicatorOnce()
        case .dismiss:
            dismiss(animated: true)
        case .showErrorMessage(let message):
            UIAlertController.presentError(in: self, withMessage: message)
        }
    }
}

private extension CGFloat {
    static let bigPadding: CGFloat = 16
    static let smallPadding: CGFloat = 8
}
