import UIKit

public final class ListViewController: UIViewController {
    private let tableView: UITableView = ListTableView()
    private let addButton: UIButton = ListAddButton()

    override public var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUserInterface()
    }

    private func setupUserInterface() {
        tableView.fill(in: view)

        view.addSubview(addButton)
        NSLayoutConstraint.activate([
            addButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -32),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
    }
}
