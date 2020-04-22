import Combine
import UIKit

public final class ListViewController: UIViewController {
    private let tableView = ListTableView()
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

    private var subscriptions: Set<AnyCancellable>
    private var actionsSubscription: AnyCancellable?

    private let viewModel: ListViewModel
    private let viewControllerFactory: ViewControllerFactory

    public init(viewModel: ListViewModel, factory: ViewControllerFactory) {
        self.viewModel = viewModel
        self.viewControllerFactory = factory
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

        self.setupTableView()
        self.setupUserInterface()
    }

    private func setupTableView() {
        tableView.register(ListTableViewCell.self, forCellReuseIdentifier: ListTableViewCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.fill(in: view)
    }

    private func setupUserInterface() {
        navigationItem.rightBarButtonItem = moreBarButtonItem

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

        viewModel.$isInSelectionMode
            .sink { [weak self] in self?.setMode(isSelection: $0) }
            .store(in: &subscriptions)

        viewModel.$selectedItemIndices
            .map { !$0.isEmpty }
            .sink { [weak self] in self?.deleteButtonItem.isEnabled = $0 }
            .store(in: &subscriptions)

        viewModel.items
            .sink { [weak self] _ in self?.tableView.reloadData() }
            .store(in: &subscriptions)

        viewModel.items
            .map { !$0.isEmpty }
            .assign(to: \.isEnabled, on: moreBarButtonItem)
            .store(in: &subscriptions)
    }

    @objc
    private func handleMoreButtonTap(_ sender: UIBarButtonItem) {
        actionsSubscription = UIAlertController.presentActionsSheet(in: self)
            .compactMap(\.title)
            .compactMap(UIAlertAction.Action.init)
            .sink(
                receiveCompletion: { [weak self] _ in self?.actionsSubscription = nil },
                receiveValue: { [weak self] in self?.handleSelectedAction($0) }
            )
    }

    @objc
    private func handleDoneButtonTap(_ sender: UIBarButtonItem) {
        viewModel.isInSelectionMode = false
    }

    @objc
    private func handleDeleteButtonTap(_ sender: UIBarButtonItem) {
        actionsSubscription = UIAlertController.presentConfirmationSheet(in: self)
            .sink(
                receiveCompletion: { [weak self] _ in self?.actionsSubscription = nil },
                receiveValue: { [weak self] _ in self?.viewModel.deleteSelectedItems() }
            )
    }

    private func setMode(isSelection: Bool) {
        tableView.setEditing(isSelection, animated: true)
        navigationItem.rightBarButtonItem = isSelection ? doneButtonItem : moreBarButtonItem
        navigationItem.leftBarButtonItem = isSelection ? deleteButtonItem : nil
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
            viewModel.isInSelectionMode = true
        default:
            break
        }
    }
}

extension ListViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfItems
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ListTableViewCell.identifier,
            for: indexPath
        ) as? ListTableViewCell

        cell?.viewModel = viewModel.cell(forIndex: indexPath.row)
        return cell ?? UITableViewCell()
    }
}

extension ListViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectedItemIndices = self.tableView.selectedIndices()

        if !tableView.isEditing {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        viewModel.selectedItemIndices = self.tableView.selectedIndices()
    }
}
