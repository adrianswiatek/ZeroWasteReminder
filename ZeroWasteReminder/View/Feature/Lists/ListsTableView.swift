import UIKit

public final class ListsTableView: UITableView {
    private let viewModel: ListsViewModel

    public init(viewModel: ListsViewModel) {
        self.viewModel = viewModel

        super.init(frame: .zero, style: .plain)

        self.configureView()
        self.registerCells()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    private func configureView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .secondarySystemBackground
        delegate = self

        layer.cornerRadius = 8
    }

    private func registerCells() {
        register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
}

extension ListsTableView: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
