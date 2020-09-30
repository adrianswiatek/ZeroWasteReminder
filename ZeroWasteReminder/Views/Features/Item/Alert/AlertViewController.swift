import Combine
import UIKit

public final class AlertViewController: UIViewController {
    private lazy var dismissButton: UIBarButtonItem =
        .dismissButton(target: self, action: #selector(handleDismiss))

    private let tableView: AlertTableView
    private let dataSource: AlertDataSource

    private let viewModel: AlertViewModel
    private var subscriptions: Set<AnyCancellable>

    public init(viewModel: AlertViewModel) {
        self.viewModel = viewModel
        self.subscriptions = []

        self.tableView = .init(viewModel)
        self.dataSource = .init(tableView, viewModel)

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
        viewModel.$selectedOption
            .sink { [weak self] in
                guard let index = self?.viewModel.indexOf($0) else { return }
                let indexPath = IndexPath(row: index, section: 0)
                self?.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
            }
            .store(in: &subscriptions)

        viewModel.requestSubject
            .filter { $0 == .dismiss }
            .sink { [weak self] _ in self?.handleDismiss() }
            .store(in: &subscriptions)
    }

    @objc
    private func handleDismiss() {
        navigationController?.popToRootViewController(animated: true)
    }
}
