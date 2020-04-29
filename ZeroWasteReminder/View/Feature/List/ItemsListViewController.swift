import Combine
import UIKit

public final class ItemsListViewController: UIViewController {
    private let addButton = ListAddButton()
    private let filterBadgeLabel = FilterBadgeLabel()

    private let itemsFilterCollectionView: ItemsFilterCollectionView
    private let itemsFilterDataSource: ItemsFilterDataSource

    private let itemsListTableView: ItemsListTableView
    private let itemsListDataSource: ItemsListDataSource
    private let itemsListDelegate: ItemsListDelegates

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

    private var subscriptions: Set<AnyCancellable>
    private var actionsSubscription: AnyCancellable?

    private let viewModel: ItemsListViewModel
    private let viewControllerFactory: ViewControllerFactory

    public init(viewModel: ItemsListViewModel, factory: ViewControllerFactory) {
        self.viewModel = viewModel
        self.viewControllerFactory = factory

        self.itemsFilterCollectionView = .init(viewModel.itemsFilterViewModel)
        self.itemsFilterDataSource = .init(itemsFilterCollectionView, viewModel.itemsFilterViewModel)

        self.itemsListTableView = .init()
        self.itemsListDataSource = .init(itemsListTableView, viewModel)
        self.itemsListDelegate = .init(viewModel)

        self.subscriptions = []

        super.init(nibName: nil, bundle: nil)

        self.bind()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUserInterface()
    }

    private func setupUserInterface() {
        navigationItem.rightBarButtonItem = moreButton
        itemsListTableView.delegate = itemsListDelegate

        if let navigationBar = navigationController?.navigationBar {
            navigationBar.addSubview(filterBadgeLabel)
            NSLayoutConstraint.activate([
                filterBadgeLabel.leadingAnchor.constraint(equalTo: navigationBar.layoutMarginsGuide.leadingAnchor, constant: 36),
                filterBadgeLabel.centerYAnchor.constraint(equalTo: navigationBar.centerYAnchor),
                filterBadgeLabel.heightAnchor.constraint(equalToConstant: 15),
                filterBadgeLabel.widthAnchor.constraint(equalToConstant: 15)
            ])
        }

        view.addSubview(itemsFilterCollectionView)
        NSLayoutConstraint.activate([
            itemsFilterCollectionView.topAnchor.constraint(equalTo: view.topAnchor),
            itemsFilterCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            itemsFilterCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            itemsFilterCollectionView.heightAnchor.constraint(equalToConstant: 0)
        ])

        view.addSubview(itemsListTableView)
        NSLayoutConstraint.activate([
            itemsListTableView.topAnchor.constraint(equalTo: itemsFilterCollectionView.bottomAnchor),
            itemsListTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            itemsListTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            itemsListTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        view.addSubview(addButton)
        NSLayoutConstraint.activate([
            addButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -32),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
    }

    private func bind() {
        addButton.tap
            .sink { [weak self] in
                guard let self = self else { return }
                self.present(self.viewControllerFactory.addViewController, animated: true)
            }
            .store(in: &subscriptions)

        viewModel.$modeState
            .sink { [weak self] in self?.updateModeState($0) }
            .store(in: &subscriptions)

        viewModel.$selectedItemIndices
            .map { !$0.isEmpty }
            .sink { [weak self] in self?.deleteButton.isEnabled = $0 }
            .store(in: &subscriptions)

        viewModel.items
            .map { !$0.isEmpty }
            .assign(to: \.isEnabled, on: moreButton)
            .store(in: &subscriptions)

        viewModel.itemsFilterViewModel.numberOfSelectedCells
            .map { $0 > 0 }
            .sink { [weak self] isFilterActive in
                self?.clearButton.isEnabled = isFilterActive
                self?.filterButton.image = isFilterActive ? .filterActive : .filter
            }
            .store(in: &subscriptions)

        viewModel.itemsFilterViewModel.numberOfSelectedCells
            .map { $0 > 0 ? String(describing: $0) : "" }
            .assign(to: \.text, on: filterBadgeLabel)
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
        actionsSubscription = UIAlertController.presentConfirmationSheet(in: self)
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
    private func handleClearButtonTap(_ sender: UIBarButtonItem) {
        viewModel.clear()
    }

    private func updateModeState(_ modeState: ModeState) {
        addButton.setVisibility(modeState.isAddButtonVisible)
        filterBadgeLabel.setVisibility(modeState.isFilterBadgeVisible)
        itemsListTableView.setEditing(modeState.isItemsListEditing, animated: true)

        navigationItem.rightBarButtonItem = rightBarButtonItem(forModeState: modeState)
        navigationItem.leftBarButtonItem = leftBarButtonItem(forModeState: modeState)

        itemsFilterCollectionView.scrollToBeginning()
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

    private func leftBarButtonItem(forModeState modeState: ModeState) -> UIBarButtonItem? {
        switch modeState {
        case _ where modeState.isFilterButtonVisible:
            return filterButton
        case _ where modeState.isDeleteButtonVisible:
            return deleteButton
        case _ where modeState.isClearButtonVisible:
            return clearButton
        default:
            return nil
        }
    }

    private func setupItemsFilterVisibility(_ modeState: ModeState) {
        let heightConstraint = itemsFilterCollectionView.constraints.last { $0.firstAttribute == .height }
        guard heightConstraint != nil else { return }

        if modeState.mode == .read, heightConstraint?.constant == 0 {
            return // Prevents animating layout when opened for the very first time
        }

        heightConstraint?.constant = modeState.mode == .filtering ? 36 : 0

        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            usingSpringWithDamping: 8,
            initialSpringVelocity: 0,
            options: .curveEaseOut,
            animations: { self.view.layoutIfNeeded() }
        )
    }

    private func handleSelectedAction(_ action: UIAlertAction.Action) {
        switch action {
        case .deleteAll:
            actionsSubscription = UIAlertController.presentConfirmationSheet(in: self)
                .sink(
                    receiveCompletion: { [weak self] _ in self?.actionsSubscription = nil },
                    receiveValue: { _ in self.viewModel.deleteAll() }
                )
        case .selectItems:
            viewModel.modeState.select(on: viewModel)
        default:
            break
        }
    }
}
