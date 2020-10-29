import Combine
import UIKit

public final class SearchViewController: UIViewController {
    private let searchBarViewController: SearchBarViewController
    private let searchTableView: SearchTableView
    private let searchDataSource: SearchDataSource

    private let viewModel: SearchViewModel
    private let coordinator: SearchCoordinator

    private var subscriptions: Set<AnyCancellable>

    public init(viewModel: SearchViewModel, coordinator: SearchCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator

        self.searchBarViewController = .init(viewModel: viewModel.searchBarViewModel)
        self.subscriptions = []

        self.searchTableView = SearchTableView()
        self.searchDataSource = SearchDataSource(searchTableView, viewModel)

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
        self.viewModel.cleanUp()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }

    private func setupView() {
        view.backgroundColor = .black

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

        searchTableView.rowSelected
            .sink { [weak self] in self?.navigateToRow(atIndex: $0) }
            .store(in: &subscriptions)
    }

    private func handleRequest(_ request: SearchViewModel.Request) {
        switch request {
        case .dismiss:
            dismiss(animated: true)
        case .showErrorMessage(let message):
            UIAlertController.presentError(in: self, withMessage: message)
        }
    }

    private func navigateToRow(atIndex index: Int) {
        coordinator.navigateToEdit(for: viewModel.item(atIndex: index), in: self)
    }
}
