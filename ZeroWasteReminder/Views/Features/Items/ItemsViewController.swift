import Combine
import UIKit

public final class ItemsViewController: UIViewController {
    private let addButton = ListAddButton(type: .system)
    private let loadingView = LoadingView()

    private let tableView: ItemsTableView
    private let dataSource: ItemsDataSource
    private let warningBarView: WarningBarView

    private lazy var moreButton: UIBarButtonItem =
        .moreButton { [weak self] in
            guard let self = self else { return }
            self.actionsSubscription = UIAlertController.presentActionsSheet(in: self)
                .compactMap { $0.title }
                .compactMap(UIAlertAction.Action.init)
                .sink(
                    receiveCompletion: { [weak self] _ in self?.actionsSubscription = nil },
                    receiveValue: { [weak self] in self?.handleSelectedAction($0) }
                )
        }

    private lazy var doneButton: UIBarButtonItem =
        .doneButton { [weak self] in self?.viewModel.done() }

    private lazy var removeButton: UIBarButtonItem =
        .deleteButton { [weak self] in
            self?.askForDeleteConfirmation(whenConfirmed: { self?.viewModel.deleteSelectedItems() })
        }

    private lazy var clearButton: UIBarButtonItem =
        .clearButton { [weak self] in self?.viewModel.clear() }

    private lazy var filterButton: UIBarButtonItem =
        .filterButton { [weak self] in self?.viewModel.filter() }

    private lazy var sortButton: UIBarButtonItem =
        .sortButton { [weak self] in self?.viewModel.sort() }

    private lazy var dismissButton: UIBarButtonItem =
        .dismissButton { [weak self] in self?.dismiss(animated: true) }

    private let itemsFilterViewController: ItemsFilterViewController

    private var subscriptions: Set<AnyCancellable>
    private var refreshSubscription: AnyCancellable?
    private var actionsSubscription: AnyCancellable?

    private let viewModel: ItemsViewModel
    private let coordinator: ItemsCoordinator

    public init(viewModel: ItemsViewModel, coordinator: ItemsCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator

        self.itemsFilterViewController = .init(viewModel.itemsFilterViewModel)

        self.tableView = .init(viewModel)
        self.dataSource = .init(tableView, viewModel)
        self.warningBarView = .init()

        self.subscriptions = []

        super.init(nibName: nil, bundle: nil)

        self.setupView()
        self.bind()

        self.viewModel.fetchItems()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupLoadingView()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.viewModel.isViewOnTop = true
        self.dataSource.initialize()
    }

    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.viewModel.isViewOnTop = false
    }

    private func setupLoadingView() {
        let navigationController: UINavigationController! = self.navigationController
        assert(navigationController != nil)

        let navigationView: UIView! = navigationController.view
        guard !navigationView.subviews.contains(loadingView) else { return }

        navigationView.addAndFill(loadingView)
    }

    private func setupView() {
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = moreButton

        addChild(itemsFilterViewController)
        view.addSubview(itemsFilterViewController.view)
        itemsFilterViewController.didMove(toParent: self)

        NSLayoutConstraint.activate([
            itemsFilterViewController.view.topAnchor.constraint(equalTo: view.topAnchor, constant: -2),
            itemsFilterViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            itemsFilterViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: itemsFilterViewController.view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        view.addSubview(warningBarView)
        NSLayoutConstraint.activate([
            warningBarView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            warningBarView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -8),
            warningBarView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor)
        ])

        view.addSubview(addButton)
        NSLayoutConstraint.activate([
            addButton.bottomAnchor.constraint(equalTo: warningBarView.topAnchor, constant: -24),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])

        view.bringSubviewToFront(itemsFilterViewController.view)
    }

    private func bind() {
        addButton.tap
            .sink { [weak self] in
                self.map { $0.coordinator.navigateToAdd(for: $0.viewModel.list, in: $0) }
            }
            .store(in: &subscriptions)

        viewModel.selectedItem
            .sink { [weak self] item in
                self.map { $0.coordinator.navigateToEdit(for: item, in: $0) }
            }
            .store(in: &subscriptions)

        viewModel.$modeState
            .sink { [weak self] in self?.updateModeState($0) }
            .store(in: &subscriptions)

        viewModel.$sortType
            .map { $0 == .ascending ? .fromSymbol(.arrowUpCircle) : .fromSymbol(.arrowDownCircle) }
            .assign(to: \.image, on: sortButton)
            .store(in: &subscriptions)

        viewModel.$selectedItemIndices
            .map { !$0.isEmpty }
            .assign(to: \.isEnabled, on: removeButton)
            .store(in: &subscriptions)

        viewModel.$items
            .map { !$0.isEmpty }
            .sink { [weak self] itemsExist in
                self?.moreButton.isEnabled = itemsExist
                self?.sortButton.isEnabled = itemsExist
            }
            .store(in: &subscriptions)

        viewModel.itemsFilterViewModel.numberOfSelectedCells
            .map { $0 > 0 }
            .sink { [weak self] in self?.handleFilterActivityChange($0) }
            .store(in: &subscriptions)

        viewModel.canRemotelyConnect
            .sink { [weak self] in self?.warningBarView.setVisibility(!$0) }
            .store(in: &subscriptions)

        viewModel.isLoading
            .sink { [weak self] in $0 ? self?.loadingView.show() : self?.loadingView.hide() }
            .store(in: &subscriptions)

        viewModel.requestsSubject
            .sink { [weak self] in self?.handleRequest($0) }
            .store(in: &subscriptions)
    }

    private func handleRequest(_ request: ItemsViewModel.Request) {
        switch request {
        case .disableLoadingIndicatorOnce:
            loadingView.disableLoadingIndicatorOnce()
        case .dismiss:
            dismissViewControllers()
        case .moveItem(let item):
            coordinator.navigateToMoveItem(with: item, in: self)
        case .removeItem(let item):
            askForDeleteConfirmation(whenConfirmed: { [weak viewModel] in viewModel?.removeItem(item) })
        case .showErrorMessage(let message):
            UIAlertController.presentError(in: self, withMessage: message)
        }
    }

    private func handleFilterActivityChange(_ isActive: Bool) {
        clearButton.isEnabled = isActive
        filterButton.image = isActive
            ? .fromSymbol(.lineHorizontal3DecreaseCircleFill)
            : .fromSymbol(.lineHorizontal3DecreaseCircle)
    }

    private func dismissViewControllers() {
        presentedViewController.map { $0.dismiss(animated: false) }
        dismiss(animated: true)
    }

    private func askForDeleteConfirmation(whenConfirmed confirmed: @escaping () -> Void) {
        actionsSubscription = UIAlertController
            .presentConfirmationSheet(in: self, withConfirmationStyle: .destructive)
            .sink(
                receiveCompletion: { [weak self] _ in self?.actionsSubscription = nil },
                receiveValue: { _ in confirmed() }
            )
    }

    private func updateModeState(_ modeState: ModeState) {
        addButton.setVisibility(modeState.isAddButtonVisible)
        tableView.setEditing(modeState.areItemsEditing, animated: true)

        navigationItem.rightBarButtonItem = rightBarButtonItem(for: modeState)
        navigationItem.leftBarButtonItems = leftBarButtonItems(for: modeState)

        itemsFilterViewController.reset()
        setupItemsFilterVisibility(modeState)
    }

    private func rightBarButtonItem(for modeState: ModeState) -> UIBarButtonItem? {
        switch modeState {
        case _ where modeState.isMoreButtonVisible: return moreButton
        case _ where modeState.isDoneButtonVisible: return doneButton
        default: return nil
        }
    }

    private func leftBarButtonItems(for modeState: ModeState) -> [UIBarButtonItem]? {
        switch modeState {
        case _ where modeState.isFilterButtonVisible: return [dismissButton, filterButton, sortButton]
        case _ where modeState.isRemoveButtonVisible: return [removeButton]
        case _ where modeState.isClearButtonVisible: return [clearButton]
        default: return nil
        }
    }

    private func setupItemsFilterVisibility(_ modeState: ModeState) {
        if modeState.mode == .read, !itemsFilterViewController.isShown {
            return // Prevents animating layout when opened for the very first time
        }

        itemsFilterViewController.setVisibility(modeState.mode == .filtering)

        UIView.animate(
            withDuration: 0.75,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0,
            options: .curveEaseOut,
            animations: { self.view.layoutIfNeeded() }
        )
    }

    private func handleSelectedAction(_ action: UIAlertAction.Action) {
        switch action {
        case .deleteAll:
            actionsSubscription = UIAlertController
                .presentConfirmationSheet(in: self, withConfirmationStyle: .destructive)
                .sink(
                    receiveCompletion: { [weak self] _ in self?.actionsSubscription = nil },
                    receiveValue: { _ in self.viewModel.removeAll() }
                )
        case .selectItems:
            viewModel.modeState.select(on: viewModel)
        case .shareList:
            coordinator.navigateToSharing(in: self)
        default:
            break
        }
    }
}
