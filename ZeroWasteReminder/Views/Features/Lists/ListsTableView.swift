import Combine
import UIKit

public final class ListsTableView: UITableView {
    private let viewModel: ListsViewModel
    private var subscriptions: Set<AnyCancellable>

    public init(_ viewModel: ListsViewModel) {
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
        backgroundColor = .systemBackground
        tableFooterView = UIView()
        delegate = self

        layer.cornerRadius = 8
    }

    private func registerCells() {
        register(ListCell.self, forCellReuseIdentifier: ListCell.identifier)
    }

    private func setupRefreshControl() {
        refreshControl = configure(UIRefreshControl()) {
            $0.addAction(.init { [weak self] _ in
                self?.viewModel.requestsSubject.send(.disableLoadingIndicatorOnce)
                self?.viewModel.fetchLists()
            }, for: .valueChanged)
        }
    }

    private func bind() {
        viewModel.requestsSubject
            .sink { [weak self] in self?.handleRequest($0) }
            .store(in: &subscriptions)

        viewModel.$lists
            .map { $0.isEmpty }
            .sink { [weak self] in
                self?.backgroundView = $0 ? EmptyTableBackgroundView(text: .localized(.noListsAddedYet)) : nil
            }
            .store(in: &subscriptions)

        viewModel.isLoading
            .filter { $0 == false }
            .sink { [weak self] _ in self?.refreshControl?.endRefreshing() }
            .store(in: &subscriptions)
    }

    private func deselectAllLists() {
        viewModel.lists.forEach { deselectList($0) }
    }

    private func indexPath(for list: List) -> IndexPath? {
        viewModel.index(of: list).map { .init(row: $0, section: 0) }
    }

    private func handleRequest(_ request: ListsViewModel.Request) {
        switch request {
        case .changeName(let list): selectList(list)
        case .discardChanges, .showErrorMessage: deselectAllLists()
        default: break
        }
    }
}

extension ListsTableView: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.requestsSubject.send(.openItems(viewModel.lists[indexPath.row]))
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
                viewModel.map { $0.requestsSubject.send(.changeName($0.lists[indexPath.row])) }
            }
        )

        let removeAction = UIAction(
            title: .localized(.removeList),
            image: .fromSymbol(.trash),
            attributes: .destructive,
            handler: { [weak viewModel] _ in
                viewModel.map { $0.requestsSubject.send(.remove($0.lists[indexPath.row])) }
            }
        )

        return UIContextMenuConfiguration(identifier: "ListsContextMenu" as NSCopying, previewProvider: nil) { _ in
            UIMenu(title: "", children: [changeNameAction, removeAction])
        }
    }
}
