import Combine
import UIKit

public final class ListViewController: UIViewController {
    private let tableView = ListTableView()
    private let addButton = ListAddButton()

    private lazy var moreBarButtonItem: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis.circle"),
            style: .plain,
            target: self,
            action: #selector(handleMoreButtonTap)
        )
        barButtonItem.tintColor = .white
        return barButtonItem
    }()

    private var subscriptions: Set<AnyCancellable>

    private let viewModel: ListViewModel
    private let viewControllerFactory: ViewControllerFactory

    public init(viewModel: ListViewModel, factory: ViewControllerFactory) {
        self.viewModel = viewModel
        self.viewControllerFactory = factory
        self.subscriptions = []
        
        super.init(nibName: nil, bundle: nil)

        self.bind()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.setupTableView()
        self.setupUserInterface()
    }

    private func setupTableView() {
        tableView.register(ListTableViewCell.self, forCellReuseIdentifier: ListTableViewCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.fill(in: view)
    }

    private func setupUserInterface() {
        navigationItem.rightBarButtonItem = moreBarButtonItem

        view.addSubview(addButton)
        NSLayoutConstraint.activate([
            addButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -32),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
    }

    private func bind() {
        addButton.tap
            .sink { [weak self] in
                guard let self = self else { return }
                self.present(self.viewControllerFactory.addViewController, animated: true)
            }
            .store(in: &subscriptions)

        viewModel.items
            .sink { [weak self] _ in self?.tableView.reloadData() }
            .store(in: &subscriptions)
    }

    @objc
    private func handleMoreButtonTap(_ sender: UIBarButtonItem) {
        print("More button tapped...")
    }
}

extension ListViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfItems
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ListTableViewCell.identifier,
            for: indexPath
        ) as? ListTableViewCell

        cell?.viewModel = viewModel.cell(forIndex: indexPath.row)
        return cell ?? UITableViewCell()
    }
}

extension ListViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
