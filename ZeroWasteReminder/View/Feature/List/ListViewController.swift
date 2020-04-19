import Combine
import UIKit

public final class ListViewController: UIViewController {
    private let temporaryItems: [String] = ["Item 1", "Item 2", "Item 3", "Item 4"]

    private let tableView = ListTableView()
    private let addButton = ListAddButton()

    private var subscriptions: [AnyCancellable] = []
    private let viewControllerFactory: ViewControllerFactory

    public init(factory: ViewControllerFactory) {
        self.viewControllerFactory = factory
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        setupUserInterface()
        setupBindings()
    }

    private func setupTableView() {
        tableView.register(ListTableViewCell.self, forCellReuseIdentifier: ListTableViewCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.fill(in: view)
    }

    private func setupUserInterface() {
        view.addSubview(addButton)
        NSLayoutConstraint.activate([
            addButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -32),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
    }

    private func setupBindings() {
        addButton.tap
            .sink { [weak self] in
                guard let self = self else { return }
                self.present(self.viewControllerFactory.addViewController, animated: true)
            }
            .store(in: &subscriptions)
    }
}

extension ListViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        temporaryItems.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ListTableViewCell.identifier,
            for: indexPath
        ) as? ListTableViewCell

        cell?.textLabel?.text = temporaryItems[indexPath.row]
        return cell ?? UITableViewCell()
    }
}

extension ListViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
