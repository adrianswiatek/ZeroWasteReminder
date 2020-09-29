import Combine
import UIKit

public final class AlertViewController: UIViewController {
    private lazy var dismissButton: UIBarButtonItem =
        .dismissButton(target: self, action: #selector(handleDismiss))

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .systemBackground
        tableView.tableFooterView = UIView()
        return tableView
    }()

    private let tableViewDataSource: UITableViewDiffableDataSource<Section, AlertOption>
    private let viewModel: AlertViewModel
    private var subscriptions: Set<AnyCancellable>

    public init(viewModel: AlertViewModel) {
        self.viewModel = viewModel
        self.subscriptions = []
        self.tableViewDataSource = .init(tableView: tableView, cellProvider: { tableView, indexPath, alertOption in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = alertOption.formatted
            return cell
        })

        super.init(nibName: nil, bundle: nil)

        navigationItem.leftBarButtonItem = dismissButton
        navigationItem.title = .localized(.alert)

        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView.delegate = self

        self.setupView()
        self.bind()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.applyOptions()
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

    private func applyOptions() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, AlertOption>()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModel.options)
        tableViewDataSource.apply(snapshot)
    }

    @objc private func handleDismiss() {
        navigationController?.popToRootViewController(animated: true)
    }
}

extension AlertViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectOption(at: indexPath.row)
    }
}

extension AlertViewController {
    public enum Section {
        case main
    }
}
