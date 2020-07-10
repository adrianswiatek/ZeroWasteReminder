import Combine
import UIKit

public final class ListsViewController: UIViewController {
    private let tableView: ListsTableView
    private let dataSource: ListsDataSource

    private let newListComponent: NewListComponent

    private let viewModel: ListsViewModel
    private let factory: ViewControllerFactory

    private var subscriptions: Set<AnyCancellable>

    public init(viewModel: ListsViewModel, factory: ViewControllerFactory) {
        self.viewModel = viewModel
        self.factory = factory

        self.tableView = .init(viewModel: viewModel)
        self.dataSource = .init(tableView, viewModel)

        self.newListComponent = .init()

        self.subscriptions = []

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

        view.addSubview(newListComponent.textField)
        NSLayoutConstraint.activate([
            newListComponent.textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            newListComponent.textField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            newListComponent.textField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])

        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: newListComponent.textField.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])

        view.addSubview(newListComponent.greenButton)
        NSLayoutConstraint.activate([
            newListComponent.greenButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
            newListComponent.greenButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
    }
}
