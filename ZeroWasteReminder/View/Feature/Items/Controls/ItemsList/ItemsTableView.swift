import UIKit

public final class ItemsTableView: UITableView {
    public init() {
        super.init(frame: .zero, style: .plain)

        translatesAutoresizingMaskIntoConstraints = false
        allowsMultipleSelectionDuringEditing = true
        backgroundColor = .systemBackground
        separatorStyle = .none

        register(
            ItemsTableViewCell.self,
            forCellReuseIdentifier: ItemsTableViewCell.identifier
        )
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    public func selectedIndices() -> [Int] {
        indexPathsForSelectedRows?.compactMap { $0.row } ?? []
    }
}
