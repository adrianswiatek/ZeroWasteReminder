import UIKit

public final class ListTableView: UITableView {
    public init() {
        super.init(frame: .zero, style: .plain)

        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .systemFill
        separatorStyle = .none
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }
}
