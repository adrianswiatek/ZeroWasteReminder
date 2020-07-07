import Combine
import UIKit

public final class ListsViewController: UIViewController {
    private let newListView: NewListView
    private let tableView: ListsTableView
    private let dataSource: ListsDataSource

    private let viewModel: ListsViewModel
    private let factory: ViewControllerFactory

    public init(viewModel: ListsViewModel, factory: ViewControllerFactory) {
        self.viewModel = viewModel
        self.factory = factory

        self.newListView = .init()
        self.tableView = .init(viewModel: viewModel)
        self.dataSource = .init(tableView, viewModel)

        super.init(nibName: nil, bundle: nil)

        self.setupView()

        self.dataSource.apply([
            "Pantry",
            "Cosmetics",
            "Alcohol",
            "Sweets",
            "Fridgerator",
            "Basement"
        ])
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    private func setupView() {
        title = "All lists"
        view.backgroundColor = .accent

        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])

        view.addSubview(newListView)
        NSLayoutConstraint.activate([
            newListView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
            newListView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
    }
}
