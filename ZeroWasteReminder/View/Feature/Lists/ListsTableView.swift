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
        self.registerCells()
        self.bind()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .secondarySystemBackground
        delegate = self

        layer.cornerRadius = 8
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
