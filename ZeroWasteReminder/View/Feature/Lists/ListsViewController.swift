import Combine
import UIKit

public final class ListsViewController: UIViewController {
    private let tableView: ListsTableView
    private let dataSource: ListsDataSource

    private let newListComponent: NewListComponent

    private let viewModel: ListsViewModel
    private let factory: ViewControllerFactory

    private var subscriptions: Set<AnyCancellable>

    private lazy var greenButtonBottomConstraint: NSLayoutConstraint = {
        let constraint = newListComponent.greenButton.bottomAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.bottomAnchor
        )
        constraint.constant = -Metrics.buttonRegularPadding
        return constraint
    }()

    public init(viewModel: ListsViewModel, factory: ViewControllerFactory) {
        self.viewModel = viewModel
        self.factory = factory

        self.tableView = .init(viewModel: viewModel)
        self.dataSource = .init(tableView, viewModel)

        self.newListComponent = .init()

        self.subscriptions = []

        super.init(nibName: nil, bundle: nil)

        self.setupView()
        self.bind()

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
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])

        view.addSubview(newListComponent.overlayView)
        NSLayoutConstraint.activate([
            newListComponent.overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            newListComponent.overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            newListComponent.overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            newListComponent.overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        view.addSubview(newListComponent.textField)
        NSLayoutConstraint.activate([
            newListComponent.textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            newListComponent.textField.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: 16
            ),
            newListComponent.textField.bottomAnchor.constraint(equalTo: tableView.topAnchor, constant: -8),
            newListComponent.textField.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -16
            ),
        ])

        view.addSubview(newListComponent.greenButton)
        NSLayoutConstraint.activate([
            greenButtonBottomConstraint,
            newListComponent.greenButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -32
            )
        ])
    }

    private func bind() {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .sink { [weak self] notification in
                notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey]
                    .flatMap { $0 as? CGRect }
                    .map { Metrics.buttonWithKeyboardPadding + $0.height }
                    .map { [weak self] in self?.setGreenButtonPadding(to: $0) }
            }
            .store(in: &subscriptions)

        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .sink { [weak self] _ in self?.setGreenButtonPadding(to: Metrics.buttonRegularPadding) }
            .store(in: &subscriptions)
    }

    private func setGreenButtonPadding(to padding: CGFloat) {
        greenButtonBottomConstraint.constant = -padding

        UIView.animate(withDuration: 0) {
            self.view.layoutIfNeeded()
        }
    }
}

private extension ListsViewController {
    enum Metrics {
        static let buttonRegularPadding: CGFloat = 32
        static let buttonWithKeyboardPadding: CGFloat = 16
    }
}
