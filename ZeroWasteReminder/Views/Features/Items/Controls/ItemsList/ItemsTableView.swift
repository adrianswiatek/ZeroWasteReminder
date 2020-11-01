import Combine
import UIKit

public final class ItemsTableView: UITableView {
    private let viewModel: ItemsViewModel
    private var subscriptions: Set<AnyCancellable>

    public init(_ viewModel: ItemsViewModel) {
        self.viewModel = viewModel
        self.subscriptions = []

        super.init(frame: .zero, style: .plain)

        self.setupView()
        self.registerCells()
        self.setupRefreshControl()
        self.bind()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    public func selectedIndices() -> [Int] {
        indexPathsForSelectedRows?.compactMap { $0.row } ?? []
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        allowsMultipleSelectionDuringEditing = true
        backgroundColor = .systemBackground
        separatorStyle = .none
        delegate = self
    }

    private func registerCells() {
        register(ItemCell.self, forCellReuseIdentifier: ItemCell.identifier)
    }

    private func setupRefreshControl() {
        refreshControl = configure(UIRefreshControl()) {
            $0.addAction(.init { [weak self] _ in
                self?.viewModel.requestsSubject.send(.disableLoadingIndicatorOnce)
                self?.viewModel.fetchItems()
            }, for: .valueChanged)
        }
    }

    private func bind() {
        viewModel.$items
            .map { $0.isEmpty }
            .sink { [weak self] in
                self?.backgroundView = $0 ? EmptyTableBackgroundView(text: .localized(.noItemsAddedYet)) : nil
            }
            .store(in: &subscriptions)

        viewModel.isLoading
            .filter { $0 == false }
            .sink { [weak self] _ in self?.refreshControl?.endRefreshing() }
            .store(in: &subscriptions)
    }
}

extension ItemsTableView: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let itemsTableView = tableView as? ItemsTableView else { return }

        viewModel.selectedItemIndices = itemsTableView.selectedIndices()

        if !tableView.isEditing {
            tableView.deselectRow(at: indexPath, animated: true)
            viewModel.selectItem(at: indexPath.row)
        }
    }

    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let itemsTableView = tableView as? ItemsTableView else { return }
        viewModel.selectedItemIndices = itemsTableView.selectedIndices()
    }

    public func tableView(
        _ tableView: UITableView,
        contextMenuConfigurationForRowAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        let editAction = UIAction(
            title: .localized(.editItem),
            image: .fromSymbol(.pencil),
            attributes: [],
            handler: { [weak viewModel] _ in
                viewModel.map { $0.selectItem(at: indexPath.row) }
            }
       )

        let moveAction = UIAction(
            title: .localized(.moveItem),
            image: .fromSymbol(.arrowRightArrowLeft),
            attributes: [],
            handler: { [weak viewModel] _ in
                viewModel.map { $0.requestsSubject.send(.moveItem($0.items[indexPath.row])) }
            }
        )

        let deleteAction = UIAction(
            title: .localized(.removeItem),
            image: .fromSymbol(.trash),
            attributes: .destructive,
            handler: { [weak viewModel] _ in
                viewModel.map { $0.requestsSubject.send(.removeItem($0.items[indexPath.row])) }
            }
        )

        return UIContextMenuConfiguration(identifier: "ItemsContextMenu" as NSCopying, previewProvider: nil) { _ in
            UIMenu(title: "", children: [editAction, moveAction, deleteAction])
        }
    }
}
