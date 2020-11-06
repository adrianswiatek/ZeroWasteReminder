import Combine
import UIKit

public final class SearchViewController: UIViewController {
    private lazy var dismissButton: UIBarButtonItem =
        .dismissButton { [weak self] in self?.dismiss(animated: true) }

    private let barViewController: SearchBarViewController
    private let tableView: SearchTableView
    private let dataSource: SearchDataSource

    private let loadingView: LoadingView

    private let viewModel: SearchViewModel
    private let coordinator: SearchCoordinator

    private var subscriptions: Set<AnyCancellable>

    public init(viewModel: SearchViewModel, coordinator: SearchCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator

        self.barViewController = .init(viewModel.searchBarViewModel)

        self.tableView = SearchTableView(viewModel)
        self.dataSource = SearchDataSource(tableView, viewModel)

        self.loadingView = .init()

        self.subscriptions = []

        super.init(nibName: nil, bundle: nil)

        self.viewModel.fetchLists()
        self.setupView()
        self.bind()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupLoadingViewIfNeeded()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.dataSource.initialize()
    }

    private func setupLoadingViewIfNeeded() {
        let navigationController: UINavigationController! = self.navigationController
        assert(navigationController != nil)

        let navigationView: UIView! = navigationController.view
        guard !navigationView.subviews.contains(loadingView) else { return }

        navigationView.addAndFill(loadingView)
    }

    private func setupView() {
        view.backgroundColor = .accent

        navigationItem.title = .localized(.search)
        navigationItem.leftBarButtonItem = dismissButton

        addSearchBarViewController()
        NSLayoutConstraint.activate([
            barViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            barViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            barViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: barViewController.view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        view.sendSubviewToBack(tableView)
        barViewController.becomeFirstResponder()
    }

    private func addSearchBarViewController() {
        addChild(barViewController)
        view.addSubview(barViewController.view)
        barViewController.didMove(toParent: self)
    }

    private func bind() {
        viewModel.requestsSubject
            .sink { [weak self] in self?.handleRequest($0) }
            .store(in: &subscriptions)

        viewModel.isLoading
            .sink { [weak self] in $0 ? self?.loadingView.show() : self?.loadingView.hide() }
            .store(in: &subscriptions)

        tableView.rowSelected
            .sink { [weak self] in self?.navigateToRow(atIndex: $0) }
            .store(in: &subscriptions)
    }

    private func handleRequest(_ request: SearchViewModel.Request) {
        switch request {
        case .showErrorMessage(let message):
            UIAlertController.presentError(in: self, withMessage: message)
        }
    }

    private func navigateToRow(atIndex index: Int) {
        coordinator.navigateToEdit(for: viewModel.item(atIndex: index), in: self)
    }
}
