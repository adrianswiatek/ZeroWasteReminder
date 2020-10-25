import Combine
import UIKit

public final class SearchViewController: UIViewController {
    private let searchBarView: SearchBarView = .init()
    private let searchTableView: UITableView = SearchTableView()

    public init() {
        super.init(nibName: nil, bundle: nil)
        self.setupView()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }

    private func setupView() {
        searchBarView.becomeFirstResponder()

        view.addSubview(searchBarView)
        NSLayoutConstraint.activate([
            searchBarView.topAnchor.constraint(equalTo: view.topAnchor),
            searchBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        view.addSubview(searchTableView)
        NSLayoutConstraint.activate([
            searchTableView.topAnchor.constraint(equalTo: searchBarView.bottomAnchor),
            searchTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            searchTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        view.sendSubviewToBack(searchTableView)
    }
}
