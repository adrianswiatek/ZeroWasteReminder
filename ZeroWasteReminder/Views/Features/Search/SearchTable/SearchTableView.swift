import Combine
import UIKit

public final class SearchTableView: UITableView {
    public var rowSelected: AnyPublisher<Int, Never> {
        selectedRowSubject.eraseToAnyPublisher()
    }

    private let viewModel: SearchViewModel
    private let selectedRowSubject: PassthroughSubject<Int, Never>

    private var subscriptions: Set<AnyCancellable>

    public init(_ viewModel: SearchViewModel) {
        self.viewModel = viewModel

        self.selectedRowSubject = .init()
        self.subscriptions = []

        super.init(frame: .zero, style: .plain)

        self.setupView()
        self.bind()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .systemBackground
        tableFooterView = UIView()

        delegate = self

        register(SearchItemCell.self, forCellReuseIdentifier: SearchItemCell.identifier)
    }

    private func bind() {
        viewModel.$items
            .map { !$0.isEmpty}
            .sink { [weak self] in self?.backgroundView = self?.backgroundView(hasItems: $0) }
            .store(in: &subscriptions)
    }

    private func backgroundView(hasItems: Bool) -> UIView? {
        if hasItems { return nil }

        return EmptyTableBackgroundView(
            text: .localized(.noItemsToShow),
            symbol: .magnifyingglass
        )
    }
}

extension SearchTableView: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedRowSubject.send(indexPath.row)
    }
}
