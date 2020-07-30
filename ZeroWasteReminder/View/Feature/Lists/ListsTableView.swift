import Combine
import UIKit

public final class ListsTableView: UITableView {
    private let viewModel: ListsViewModel
    private var subscriptions: Set<AnyCancellable>

    public init(viewModel: ListsViewModel) {
        self.viewModel = viewModel
        self.subscriptions = []

        super.init(frame: .zero, style: .plain)

        self.setupView()
        self.setupRefreshControl()
        self.registerCells()
        self.bind()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    public func selectList(_ list: List) {
        indexPath(for: list).map { indexPath in
            selectRow(at: indexPath, animated: true, scrollPosition: .none)
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250)) {
                self.scrollToRow(at: indexPath, at: .top, animated: true)
            }
        }
    }

    public func deselectList(_ list: List) {
        indexPath(for: list).map { deselectRow(at: $0, animated: true) }
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .secondarySystemBackground
        delegate = self

        layer.cornerRadius = 8
    }

    private func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.tintColor = .clear
        refreshControl?.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
    }

    private func registerCells() {
        register(ListCell.self, forCellReuseIdentifier: ListCell.identifier)
    }

    private func bind() {
        viewModel.requestsSubject
            .filter { $0 == .discardChanges }
            .map { _ in }
            .sink { [weak self] in self?.deselectRows() }
            .store(in: &subscriptions)
    }

    private func deselectRows() {
        visibleCells.filter { $0.isSelected }.forEach { $0.setSelected(false, animated: true) }
    }

    @objc
    private func handleRefresh() {
        refreshControl?.endRefreshing()
        viewModel.fetchLists()
    }

    private func indexPath(for list: List) -> IndexPath? {
        viewModel.index(of: list).map { .init(row: $0, section: 0) }
    }
}

extension ListsTableView: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.requestsSubject.send(.openItems(viewModel.list(at: indexPath.row)))
    }

    public func tableView(
        _ tableView: UITableView,
        contextMenuConfigurationForRowAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        let changeNameAction = UIAction(
            title: .localized(.changeName),
            image: .fromSymbol(.pencil),
            attributes: [],
            handler: { [weak viewModel] _ in
                viewModel.map { $0.requestsSubject.send(.changeName($0.list(at: indexPath.row))) }
            }
        )

        let removeAction = UIAction(
            title: .localized(.removeList),
            image: .fromSymbol(.trash),
            attributes: .destructive,
            handler: { [weak viewModel] _ in
                viewModel.map { $0.requestsSubject.send(.remove($0.list(at: indexPath.row))) }
            }
        )

        return UIContextMenuConfiguration(identifier: "ListsContextMenu" as NSCopying, previewProvider: nil) { _ in
            UIMenu(title: "", children: [changeNameAction, removeAction])
        }
    }
}
