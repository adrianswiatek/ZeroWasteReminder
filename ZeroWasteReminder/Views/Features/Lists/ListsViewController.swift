import Combine
import UIKit

public final class ListsViewController: UIViewController {
    private let tableView: ListsTableView
    private let dataSource: ListsDataSource

    private lazy var searchBarButtonItem: UIBarButtonItem =
        .searchButton(target: self, action: #selector(handleSearchButtonTap))

    private let loadingView: LoadingView
    private let warningBarView: WarningBarView
    private let editListComponent: EditListComponent

    private let viewModel: ListsViewModel
    private let coordinator: ListsCoordinator
    private let notificationCenter: NotificationCenter

    private var removeListSubscription: AnyCancellable?
    private var subscriptions: Set<AnyCancellable>

    private lazy var buttonsBottomConstraint: NSLayoutConstraint =
        editListComponent.buttons.bottomAnchor.constraint(
            equalTo: tableView.bottomAnchor,
            constant: -.buttonVerticalPadding
        )

    public init(
        viewModel: ListsViewModel,
        coordinator: ListsCoordinator,
        notificationCenter: NotificationCenter
    ) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        self.notificationCenter = notificationCenter

        self.tableView = .init(viewModel: viewModel)
        self.dataSource = .init(tableView, viewModel)

        self.loadingView = .init()
        self.warningBarView = .init()
        self.editListComponent = .init(viewModel: viewModel)

        self.subscriptions = []

        super.init(nibName: nil, bundle: nil)

        self.setupView()
        self.bind()

        self.viewModel.fetchLists()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.viewModel.isViewOnTop = true
    }

    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.viewModel.isViewOnTop = false
    }

    private func setupView() {
        title = .localized(.allLists)
        view.backgroundColor = .accent
        loadingView.backgroundColor = UIColor.accent.withAlphaComponent(0.35)
        navigationItem.rightBarButtonItem = searchBarButtonItem

        view.addSubview(warningBarView)
        NSLayoutConstraint.activate([
            warningBarView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            warningBarView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -.smallPadding),
            warningBarView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor)
        ])

        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: .bigPadding),
            tableView.bottomAnchor.constraint(equalTo: warningBarView.topAnchor, constant: -.smallPadding),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -.bigPadding)
        ])

        view.addSubview(editListComponent.overlay)
        NSLayoutConstraint.activate([
            editListComponent.overlay.topAnchor.constraint(equalTo: view.topAnchor),
            editListComponent.overlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            editListComponent.overlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            editListComponent.overlay.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        view.addSubview(editListComponent.textField)
        NSLayoutConstraint.activate([
            editListComponent.textField.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor
            ),
            editListComponent.textField.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: .bigPadding
            ),
            editListComponent.textField.bottomAnchor.constraint(
                equalTo: tableView.topAnchor, constant: -.smallPadding
            ),
            editListComponent.textField.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -.bigPadding
            )
        ])

        view.addSubview(editListComponent.buttons)
        NSLayoutConstraint.activate([
            buttonsBottomConstraint,
            editListComponent.buttons.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -.buttonHorizontalPadding
            )
        ])

        view.addSubview(loadingView)
        NSLayoutConstraint.activate([
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func bind() {
        notificationCenter.publisher(for: UIResponder.keyboardWillShowNotification)
            .sink { [weak self] notification in
                notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey]
                    .flatMap { ($0 as? CGRect)?.height }
                    .map { [weak self] height in
                        self.map { $0.setButtonsBottomPadding(to: height - $0.warningBarView.height) }
                    }
            }
            .store(in: &subscriptions)

        notificationCenter.publisher(for: UIResponder.keyboardWillHideNotification)
            .sink { [weak self] _ in self?.setButtonsBottomPadding(to: .buttonVerticalPadding) }
            .store(in: &subscriptions)

        viewModel.requestsSubject
            .sink { [weak self] in self?.handleRequest($0) }
            .store(in: &subscriptions)

        viewModel.isLoading
            .sink { [weak self] in $0 ? self?.loadingView.show() : self?.loadingView.hide() }
            .store(in: &subscriptions)

        viewModel.canRemotelyConnect
            .sink { [weak self] in self?.warningBarView.setVisibility(!$0) }
            .store(in: &subscriptions)
    }

    private func handleRequest(_ request: ListsViewModel.Request) {
        switch request {
        case .disableLoadingIndicatorOnce:
            loadingView.disableLoadingIndicatorOnce()
        case .openItems(let list):
            coordinator.navigateToItems(with: list, in: self)
        case .remove(let list):
            removeListSubscription = UIAlertController.presentRemoveListConfirmationSheet(in: self).sink(
                receiveCompletion: { [weak self] _ in self?.tableView.deselectList(list) },
                receiveValue: { [weak self] _ in self?.viewModel.removeList(list) }
            )
        case .showErrorMessage(let message):
            UIAlertController.presentError(in: self, withMessage: message)
        case .changeName, .discardChanges:
            break
        }
    }

    private func setButtonsBottomPadding(to padding: CGFloat) {
        buttonsBottomConstraint.constant = -padding

        UIView.animate(withDuration: 0) {
            self.view.layoutIfNeeded()
        }
    }

    @objc
    private func handleSearchButtonTap() {
        print("Search button tapped")
    }
}

private extension CGFloat {
    static let buttonVerticalPadding: CGFloat = 20
    static let buttonHorizontalPadding: CGFloat = 40

    static let smallPadding: CGFloat = 8
    static let bigPadding: CGFloat = 16
}
