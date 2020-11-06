import Combine
import UIKit

public final class MoveItemTableView: UITableView {
    private let viewModel: MoveItemViewModel
    private var subscriptions: Set<AnyCancellable>

    public init(_ viewModel: MoveItemViewModel) {
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

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .systemBackground
        separatorStyle = .none
        tableFooterView = UIView()
        delegate = self

        layer.cornerRadius = 16
        layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }

    private func registerCells() {
        register(MoveItemListCell.self, forCellReuseIdentifier: MoveItemListCell.identifier)
    }

    private func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addAction(UIAction { [weak self] _ in
            self?.viewModel.requestsSubject.send(.disableLoadingIndicatorOnce)
            self?.viewModel.fetchLists()
        }, for: .touchUpInside)
    }

    private func bind() {
        viewModel.$lists
            .map { $0.isEmpty }
            .sink { [weak self] in
                self?.backgroundView = $0 ? EmptyTableBackgroundView(text: .localized(.noListsAvailable)) : nil
            }
            .store(in: &subscriptions)

        viewModel.isLoading
            .filter { $0 == false }
            .sink { [weak self] _ in self?.refreshControl?.endRefreshing() }
            .store(in: &subscriptions)
    }
}

extension MoveItemTableView: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectList(viewModel.lists[indexPath.row])
    }
}
