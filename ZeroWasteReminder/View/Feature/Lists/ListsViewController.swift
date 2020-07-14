import Combine
import UIKit

public final class ListsViewController: UIViewController {
    private let tableView: ListsTableView
    private let dataSource: ListsDataSource

    private let newListComponent: NewListComponent

    private let viewModel: ListsViewModel
    private let factory: ViewControllerFactory
    private let notificationCenter: NotificationCenter

    private var subscriptions: Set<AnyCancellable>

    private lazy var buttonsBottomConstraint: NSLayoutConstraint =
        newListComponent.buttons.bottomAnchor.constraint(
            equalTo: view.bottomAnchor,
            constant: -Metrics.buttonsRegularPadding
        )

    public init(
        viewModel: ListsViewModel,
        factory: ViewControllerFactory,
        notificationCenter: NotificationCenter
    ) {
        self.viewModel = viewModel
        self.factory = factory
        self.notificationCenter = notificationCenter

        self.tableView = .init(viewModel: viewModel)
        self.dataSource = .init(tableView, viewModel)

        self.newListComponent = .init(viewModel: viewModel)

        self.subscriptions = []

        super.init(nibName: nil, bundle: nil)

        self.setupView()
        self.bind()
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
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -24),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])

        view.addSubview(newListComponent.overlay)
        NSLayoutConstraint.activate([
            newListComponent.overlay.topAnchor.constraint(equalTo: view.topAnchor),
            newListComponent.overlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            newListComponent.overlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            newListComponent.overlay.trailingAnchor.constraint(equalTo: view.trailingAnchor)
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

        view.addSubview(newListComponent.buttons)
        NSLayoutConstraint.activate([
            buttonsBottomConstraint,
            newListComponent.buttons.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -Metrics.buttonsRegularPadding
            )
        ])
    }

    private func bind() {
        notificationCenter.publisher(for: UIResponder.keyboardWillShowNotification)
            .sink { [weak self] notification in
                notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey]
                    .flatMap { $0 as? CGRect }
                    .map { Metrics.buttonWithKeyboardPadding + $0.height }
                    .map { [weak self] in self?.setButtonsBottomPadding(to: $0) }
            }
            .store(in: &subscriptions)

        notificationCenter.publisher(for: UIResponder.keyboardWillHideNotification)
            .sink { [weak self] _ in self?.setButtonsBottomPadding(to: Metrics.buttonsRegularPadding) }
            .store(in: &subscriptions)
    }

    private func setButtonsBottomPadding(to padding: CGFloat) {
        buttonsBottomConstraint.constant = -padding

        UIView.animate(withDuration: 0) {
            self.view.layoutIfNeeded()
        }
    }
}

private extension ListsViewController {
    enum Metrics {
        static let buttonsRegularPadding: CGFloat = 40
        static let buttonWithKeyboardPadding: CGFloat = 16
    }
}
