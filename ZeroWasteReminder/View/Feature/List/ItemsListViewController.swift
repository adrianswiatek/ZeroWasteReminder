import Combine
import UIKit

public final class ItemsListViewController: UIViewController {
    private let addButton = ListAddButton()
    private let filterBadgeLabel = FilterBadgeLabel()
    private let loadingView = LoadingView()

    private let itemsListTableView: ItemsListTableView
    private let itemsListDataSource: ItemsListDataSource
    private let itemsListDelegate: ItemsListDelegate
    private let warningBarView: WarningBarView

    private lazy var moreButton: UIBarButtonItem =
        .moreButton(target: self, action: #selector(handleMoreButtonTap))

    private lazy var doneButton: UIBarButtonItem =
        .doneButton(target: self, action: #selector(handleDoneButtonTap))

    private lazy var deleteButton: UIBarButtonItem =
        .deleteButton(target: self, action: #selector(handleDeleteButtonTap))

    private lazy var clearButton: UIBarButtonItem =
        .clearButton(target: self, action: #selector(handleClearButtonTap))

    private lazy var filterButton: UIBarButtonItem =
        .filterButton(target: self, action: #selector(handleFilterButtonTap))

    private lazy var sortButton: UIBarButtonItem =
        .sortButton(target: self, action: #selector(handleSortButtonTap))

    private let itemsFilterViewController: ItemsFilterViewController

    private var subscriptions: Set<AnyCancellable>
    private var actionsSubscription: AnyCancellable?

    private let viewModel: ItemsListViewModel
    private let viewControllerFactory: ViewControllerFactory

    public init(viewModel: ItemsListViewModel, factory: ViewControllerFactory) {
        self.viewModel = viewModel
        self.viewControllerFactory = factory

        self.itemsFilterViewController = .init(viewModel.itemsFilterViewModel)

        self.itemsListTableView = .init()
        self.itemsListDataSource = .init(itemsListTableView, viewModel)
        self.itemsListDelegate = .init(viewModel)
        self.warningBarView = .init()

        self.subscriptions = []

        super.init(nibName: nil, bundle: nil)

        self.setupView()
        self.setupTableView()
        self.bind()

        self.refreshList(withLoadingIndicator: true)
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavigationControllerIfNeeded()
    }

    private func setupNavigationControllerIfNeeded() {
        let navigationController: UINavigationController! = self.navigationController
        assert(navigationController != nil)

        let navigationBar = navigationController.navigationBar
        navigationBar.addSubview(filterBadgeLabel)
        NSLayoutConstraint.activate([
            filterBadgeLabel.leadingAnchor.constraint(
                equalTo: navigationBar.layoutMarginsGuide.leadingAnchor,
                constant: 36
            ),
            filterBadgeLabel.centerYAnchor.constraint(equalTo: navigationBar.centerYAnchor),
            filterBadgeLabel.heightAnchor.constraint(equalToConstant: 15),
            filterBadgeLabel.widthAnchor.constraint(equalToConstant: 15)
        ])

        let navigationView: UIView! = navigationController.view
        navigationView.addSubview(loadingView)
        NSLayoutConstraint.activate([
            loadingView.topAnchor.constraint(equalTo: navigationView.topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: navigationView.leadingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: navigationView.bottomAnchor),
            loadingView.trailingAnchor.constraint(equalTo: navigationView.trailingAnchor)
        ])
    }

    private func setupView() {
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = moreButton

        addChild(itemsFilterViewController)
        view.addSubview(itemsFilterViewController.view)
        itemsFilterViewController.didMove(toParent: self)

        NSLayoutConstraint.activate([
            itemsFilterViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            itemsFilterViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            itemsFilterViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        view.addSubview(itemsListTableView)
        NSLayoutConstraint.activate([
            itemsListTableView.topAnchor.constraint(equalTo: itemsFilterViewController.view.bottomAnchor),
            itemsListTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            itemsListTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            itemsListTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        view.addSubview(warningBarView)
        NSLayoutConstraint.activate([
            warningBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            warningBarView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            warningBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        view.addSubview(addButton)
        NSLayoutConstraint.activate([
            addButton.bottomAnchor.constraint(equalTo: warningBarView.topAnchor, constant: -32),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])

        view.bringSubviewToFront(itemsFilterViewController.view)
    }

    private func setupTableView() {
        itemsListTableView.delegate = self.itemsListDelegate

        itemsListTableView.refreshControl = UIRefreshControl()
        itemsListTableView.refreshControl?.addTarget(self, action: #selector(refreshList), for: .valueChanged)
    }

    private func bind() {
        addButton.tap
            .sink { [weak self] in
                guard let self = self else { return }
                self.present(self.viewControllerFactory.addViewController, animated: true)
            }
            .store(in: &subscriptions)

        viewModel.selectedItem
            .sink { [weak self] in
                guard let self = self else { return }
                let editViewController = self.viewControllerFactory.editViewController(item: $0)
                self.navigationController?.pushViewController(editViewController, animated: true)
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
            .assign(to: \.isEnabled, on: deleteButton)
            .store(in: &subscriptions)

        viewModel.items
            .map { !$0.isEmpty }
            .sink { [weak self] itemsExist in
                self?.moreButton.isEnabled = itemsExist
                self?.sortButton.isEnabled = itemsExist
            }
            .store(in: &subscriptions)

        viewModel.itemsFilterViewModel.numberOfSelectedCells
            .map { $0 > 0 }
            .sink { [weak self] isFilterActive in
                self?.clearButton.isEnabled = isFilterActive
                self?.filterButton.image = isFilterActive
                    ? .fromSymbol(.lineHorizontal3DecreaseCircleFill)
                    : .fromSymbol(.lineHorizontal3DecreaseCircle)
            }
            .store(in: &subscriptions)

        viewModel.itemsFilterViewModel.numberOfSelectedCells
            .map { $0 > 0 ? String(describing: $0) : "" }
            .assign(to: \.text, on: filterBadgeLabel)
            .store(in: &subscriptions)

        viewModel.canRemotelyConnect
            .sink { [weak self] in self?.warningBarView.setVisibility(!$0) }
            .store(in: &subscriptions)
    }

    @objc
    private func refreshList(withLoadingIndicator: Bool = false) {
        loadingView.show(withLoadingIndicator: withLoadingIndicator)

        viewModel.refreshList()
            .sink(
                receiveCompletion: { [weak self] _ in
                    self?.itemsListTableView.refreshControl?.endRefreshing()
                    self?.loadingView.hide()
                },
                receiveValue: {}
            )
            .store(in: &subscriptions)
    }

    @objc
    private func handleMoreButtonTap(_ sender: UIBarButtonItem) {
        actionsSubscription = UIAlertController.presentActionsSheet(in: self)
            .compactMap { $0.title }
            .compactMap(UIAlertAction.Action.init)
            .sink(
                receiveCompletion: { [weak self] _ in self?.actionsSubscription = nil },
                receiveValue: { [weak self] in self?.handleSelectedAction($0) }
            )
    }

    @objc
    private func handleDoneButtonTap(_ sender: UIBarButtonItem) {
        viewModel.done()
    }

    @objc
    private func handleDeleteButtonTap(_ sender: UIBarButtonItem) {
        actionsSubscription = UIAlertController
            .presentConfirmationSheet(in: self, withConfirmationStyle: .destructive)
            .sink(
                receiveCompletion: { [weak self] _ in self?.actionsSubscription = nil },
                receiveValue: { [weak self] _ in self?.viewModel.deleteSelectedItems() }
            )
    }

    @objc
    private func handleFilterButtonTap(_ sender: UIBarButtonItem) {
        viewModel.filter()
    }

    @objc
    private func handleSortButtonTap(_ sender: UIBarButtonItem) {
        viewModel.sort()
    }

    @objc
    private func handleClearButtonTap(_ sender: UIBarButtonItem) {
        viewModel.clear()
    }

    private func updateModeState(_ modeState: ModeState) {
        addButton.setVisibility(modeState.isAddButtonVisible)
        filterBadgeLabel.setVisibility(modeState.isFilterBadgeVisible)
        itemsListTableView.setEditing(modeState.isItemsListEditing, animated: true)

        navigationItem.rightBarButtonItem = rightBarButtonItem(forModeState: modeState)
        navigationItem.leftBarButtonItems = leftBarButtonItems(forModeState: modeState)

        itemsFilterViewController.reset()
        setupItemsFilterVisibility(modeState)
    }

    private func rightBarButtonItem(forModeState modeState: ModeState) -> UIBarButtonItem? {
        switch modeState {
        case _ where modeState.isMoreButtonVisible:
            return moreButton
        case _ where modeState.isDoneButtonVisible:
            return doneButton
        default:
            return nil
        }
    }

    private func leftBarButtonItems(forModeState modeState: ModeState) -> [UIBarButtonItem]? {
        switch modeState {
        case _ where modeState.isFilterButtonVisible:
            return [filterButton, sortButton]
        case _ where modeState.isDeleteButtonVisible:
            return [deleteButton]
        case _ where modeState.isClearButtonVisible:
            return [clearButton]
        default:
            return nil
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
                    receiveValue: { _ in self.viewModel.deleteAll() }
                )
        case .selectItems:
            viewModel.modeState.select(on: viewModel)
        case .shareList:
            present(viewControllerFactory.sharingController, animated: true)
        default:
            break
        }
    }
}
