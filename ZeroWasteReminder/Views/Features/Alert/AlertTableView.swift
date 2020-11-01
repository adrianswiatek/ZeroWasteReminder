import Combine
import UIKit

public final class AlertTableView: UITableView {
    private let viewModel: AlertViewModel
    private var subscriptions: Set<AnyCancellable>

    public init(_ viewModel: AlertViewModel) {
        self.viewModel = viewModel
        self.subscriptions = []

        super.init(frame: .zero, style: .plain)

        self.setupView()
        self.registerCells()
        self.bind()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        separatorStyle = .none
        tableFooterView = UIView()

        delegate = self
        dataSource = self
    }

    private func registerCells() {
        register(AlertOptionCell.self, forCellReuseIdentifier: AlertOptionCell.identifier)
        register(AlertDateCell.self, forCellReuseIdentifier: AlertDateCell.identifier)
        register(AlertCalendarCell.self, forCellReuseIdentifier: AlertCalendarCell.identifier)
    }

    private func bind() {
        viewModel.$selectedOption
            .sink { [weak self] in
                guard let index = self?.viewModel.indexOf($0) else { return }
                self?.selectRow(at: .init(row: index, section: 0), animated: true, scrollPosition: .top)
            }
            .store(in: &subscriptions)

        viewModel.requestSubject
            .sink { [weak self] in self?.handleRequest($0) }
            .store(in: &subscriptions)
    }

    private func handleRequest(_ request: AlertViewModel.Request) {
        switch request {
        case .showCalendar:
            let indexPath = IndexPath(row: viewModel.numberOfCells - 1, section: 0)
            insertRows(at: .just(indexPath), with: .fade)
            scrollToRow(at: indexPath, at: .top, animated: true)
        case .hideCalendar:
            deleteRows(at: .just(.init(row: viewModel.numberOfCells, section: 0)), with: .fade)
        default:
            return
        }
    }
}

extension AlertTableView: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath).map { $0.setSelected(true, animated: true) }
        viewModel.selectCell(at: indexPath.row)
    }
}

extension AlertTableView: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfCells
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch viewModel.cellDataForRow(at: indexPath.row) {
        case .option(let option):
            return configure(dequeueCell(at: indexPath) as AlertOptionCell) {
                $0.set(option)
            }
        case .date:
            return configure(dequeueCell(at: indexPath) as AlertDateCell) {
                $0.set(viewModel.dateCellViewModel)
            }
        case .calendar:
            return configure(dequeueCell(at: indexPath) as AlertCalendarCell) {
                $0.set(viewModel.dateCellViewModel)
            }
        }
    }

    private func dequeueCell<T: UITableViewCell>(at indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: T.identifier, for: indexPath) as? T else {
            preconditionFailure("Unable to dequeue table view cell.")
        }
        return cell
    }
}
