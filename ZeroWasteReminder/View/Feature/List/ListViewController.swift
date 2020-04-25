import Combine
import UIKit

public final class ListViewController: UIViewController {
    private let itemsFilterCollectionView: ItemsFilterCollectionView
    private let itemsListTableView: ItemsListTableView
    private let addButton = ListAddButton()

    private lazy var moreBarButtonItem: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis.circle"),
            style: .plain,
            target: self,
            action: #selector(handleMoreButtonTap)
        )
        barButtonItem.tintColor = .white
        return barButtonItem
    }()

    private lazy var doneButtonItem: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(handleDoneButtonTap)
        )
        barButtonItem.tintColor = .white
        return barButtonItem
    }()

    private lazy var deleteButtonItem: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(
            title: "Delete",
            style: .plain,
            target: self,
            action: #selector(handleDeleteButtonTap)
        )
        barButtonItem.tintColor = .white
        barButtonItem.isEnabled = false
        return barButtonItem
    }()

    private let itemsFilterDataSource: ItemsFilterDataSource
    private let itemsListDataSource: ItemsListDataSource

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

        self.subscriptions = []

        super.init(nibName: nil, bundle: nil)

        self.setupUserInterface()
        self.bind()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    private func setupUserInterface() {
        navigationItem.rightBarButtonItem = moreBarButtonItem
        itemsListTableView.delegate = self

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

        viewModel.$mode
            .sink { [weak self] in self?.setMode($0) }
            .store(in: &subscriptions)

        viewModel.$selectedItemIndices
            .map { !$0.isEmpty }
            .sink { [weak self] in self?.deleteButtonItem.isEnabled = $0 }
            .store(in: &subscriptions)

        viewModel.items
            .map { !$0.isEmpty }
            .assign(to: \.isEnabled, on: moreBarButtonItem)
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
        viewModel.mode = .read
    }

    @objc
    private func handleDeleteButtonTap(_ sender: UIBarButtonItem) {
        actionsSubscription = UIAlertController.presentConfirmationSheet(in: self)
            .sink(
                receiveCompletion: { [weak self] _ in self?.actionsSubscription = nil },
                receiveValue: { [weak self] _ in self?.viewModel.deleteSelectedItems() }
            )
    }

    private func setMode(_ mode: ItemsListViewModel.Mode) {
        viewModel.selectedItemIndices = []

        addButton.setVisibility(mode == .read)
        itemsListTableView.setEditing(mode == .selection, animated: true)
        itemsFilterCollectionView.scrollToBeginning()
        navigationItem.rightBarButtonItem = mode != .read ? doneButtonItem : moreBarButtonItem
        navigationItem.leftBarButtonItem = mode == .selection ? deleteButtonItem : nil

        setupItemsFilterVisibility(mode)
    }

    private func setupItemsFilterVisibility(_ mode: ItemsListViewModel.Mode) {
        let heightConstraint = itemsFilterCollectionView.constraints.last { $0.firstAttribute == .height }
        guard heightConstraint != nil else { return }

        if mode == .read, heightConstraint?.constant == 0 {
            return
        }

        heightConstraint?.constant = mode == .filtering ? 36 : 0

        UIView.animate(
            withDuration: 0.5,
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
        case .filterItems:
            viewModel.mode = .filtering
        case .selectItems:
            viewModel.mode = .selection
        default:
            break
        }
    }
}

extension ListViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectedItemIndices = self.itemsListTableView.selectedIndices()

        if !tableView.isEditing {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        viewModel.selectedItemIndices = self.itemsListTableView.selectedIndices()
    }
}
