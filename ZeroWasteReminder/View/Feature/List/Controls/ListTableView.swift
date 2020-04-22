import UIKit

public final class ListTableView: UITableView {
    public init() {
        super.init(frame: .zero, style: .plain)

        translatesAutoresizingMaskIntoConstraints = false
        allowsMultipleSelectionDuringEditing = true
        backgroundColor = .white
        separatorStyle = .none
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    public func selectedIndices() -> [Int] {
        indexPathsForSelectedRows?.compactMap { $0.row } ?? []
    }
}
