import Combine
import UIKit

public final class SearchViewController: UIViewController {
    private lazy var dismissButton: UIBarButtonItem =
        .dismissButton(target: self, action: #selector(handleDismissButtonTap))

    private let searchBarViewController: SearchBarViewController
    private let searchTableView: SearchTableView
    private let searchDataSource: SearchDataSource

    private let loadingView: LoadingView

    private let viewModel: SearchViewModel
    private let coordinator: SearchCoordinator

    private var subscriptions: Set<AnyCancellable>

    public init(viewModel: SearchViewModel, coordinator: SearchCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator

        self.searchBarViewController = .init(viewModel: viewModel.searchBarViewModel)

        self.searchTableView = SearchTableView(viewModel)
        self.searchDataSource = SearchDataSource(searchTableView, viewModel)

        self.loadingView = .init()

        self.subscriptions = []

        super.init(nibName: nil, bundle: nil)

        self.viewModel.initialize()
        self.setupView()
        self.bind()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    deinit {
        viewModel.cleanUp()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupLoadingViewIfNeeded()
        self.setupNavigationItem()
    }

    private func setupLoadingViewIfNeeded() {
        let navigationController: UINavigationController! = self.navigationController
        assert(navigationController != nil)

        let navigationView: UIView! = navigationController.view
        guard !navigationView.subviews.contains(loadingView) else { return }

        navigationView.addSubview(loadingView)
        NSLayoutConstraint.activate([
            loadingView.topAnchor.constraint(equalTo: navigationView.topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: navigationView.leadingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: navigationView.bottomAnchor),
            loadingView.trailingAnchor.constraint(equalTo: navigationView.trailingAnchor)
        ])
    }

    private func setupNavigationItem() {
        navigationItem.title = .localized(.search)
        navigationItem.leftBarButtonItem = dismissButton
    }

    private func setupView() {
        view.backgroundColor = .accent

        addSearchBarViewController()
        NSLayoutConstraint.activate([
            searchBarViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            searchBarViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBarViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        view.addSubview(searchTableView)
        NSLayoutConstraint.activate([
            searchTableView.topAnchor.constraint(equalTo: searchBarViewController.view.bottomAnchor),
            searchTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            searchTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        view.sendSubviewToBack(searchTableView)
        searchBarViewController.becomeFirstResponder()
    }

    private func addSearchBarViewController() {
        addChild(searchBarViewController)
        view.addSubview(searchBarViewController.view)
        searchBarViewController.didMove(toParent: self)
    }

    private func bind() {
        viewModel.requestsSubject
            .sink { [weak self] in self?.handleRequest($0) }
            .store(in: &subscriptions)

        viewModel.isLoading
            .sink { [weak self] in $0 ? self?.loadingView.show() : self?.loadingView.hide() }
            .store(in: &subscriptions)

        searchTableView.rowSelected
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

    @objc
    private func handleDismissButtonTap() {
        dismiss(animated: true)
    }
}
