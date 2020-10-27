import Combine
import UIKit

public final class SearchViewController: UIViewController {
    private let searchBarViewController: SearchBarViewController
    private let searchTableView: UITableView = SearchTableView()

    private let viewModel: SearchViewModel
    private var subscriptions: Set<AnyCancellable>

    public init(viewModel: SearchViewModel) {
        self.viewModel = viewModel
        self.searchBarViewController = .init(viewModel: viewModel.searchBarViewModel)
        self.subscriptions = []

        super.init(nibName: nil, bundle: nil)

        self.setupView()
        self.bind()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
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
        viewModel.requestSubject
            .sink { [weak self] in self?.handleRequest($0) }
            .store(in: &subscriptions)
    }

    private func handleRequest(_ request: SearchViewModel.Request) {
        switch request {
        case .dismiss:
            dismiss(animated: true)
        }
    }
}
