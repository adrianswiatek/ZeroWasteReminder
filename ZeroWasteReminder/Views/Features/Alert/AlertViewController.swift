import Combine
import UIKit

public final class AlertViewController: UIViewController {
    private lazy var dismissButton: UIBarButtonItem =
        .dismissButton(target: self, action: #selector(handleDismiss))

    private let tableView: AlertTableView

    private let viewModel: AlertViewModel
    private var subscriptions: Set<AnyCancellable>

    public init(viewModel: AlertViewModel) {
        self.viewModel = viewModel

        self.tableView = .init(viewModel)
        self.subscriptions = []

        super.init(nibName: nil, bundle: nil)

        navigationItem.leftBarButtonItem = dismissButton
        navigationItem.title = .localized(.alert)

        self.setupView()
        self.bind()
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
    }

    private func bind() {
        viewModel.requestSubject
            .sink { [weak self] in self?.handleRequest($0) }
            .store(in: &subscriptions)
    }

    private func handleRequest(_ request: AlertViewModel.Request) {
        switch request {
        case .dismiss: handleDismiss()
        default: return
        }
    }

    @objc
    private func handleDismiss() {
        navigationController?.popViewController(animated: true)
    }
}
