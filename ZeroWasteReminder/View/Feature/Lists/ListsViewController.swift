import Combine
import UIKit

public final class ListsViewController: UIViewController {
    private let tableView: ListsTableView
    private let dataSource: ListsDataSource

    private let editListComponent: EditListComponent

    private let viewModel: ListsViewModel
    private let factory: ViewControllerFactory
    private let notificationCenter: NotificationCenter

    private var removeListSubscription: AnyCancellable?
    private var subscriptions: Set<AnyCancellable>

    private lazy var buttonsBottomConstraint: NSLayoutConstraint =
        editListComponent.buttons.bottomAnchor.constraint(
            equalTo: view.bottomAnchor,
            constant: -.buttonsRegularPadding
        )

    public init(
        viewModel: ListsViewModel,
        factory: ViewControllerFactory,
        notificationCenter: NotificationCenter
    ) {
        self.viewModel = viewModel
        self.factory = factory
        self.notificationCenter = notificationCenter

        self.tableView = .init(viewModel: viewModel)
        self.dataSource = .init(tableView, viewModel)

        self.editListComponent = .init(viewModel: viewModel)

        self.subscriptions = []

        super.init(nibName: nil, bundle: nil)

        self.setupView()
        self.bind()

        self.viewModel.fetchLists()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    private func setupView() {
        title = .localized(.allLists)
        view.backgroundColor = .accent

        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: .bigPadding),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -.smallPadding * 3),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -.bigPadding)
        ])

        view.addSubview(editListComponent.overlay)
        NSLayoutConstraint.activate([
            editListComponent.overlay.topAnchor.constraint(equalTo: view.topAnchor),
            editListComponent.overlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            editListComponent.overlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            editListComponent.overlay.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        view.addSubview(editListComponent.textField)
        NSLayoutConstraint.activate([
            editListComponent.textField.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: .smallPadding
            ),
            editListComponent.textField.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: .bigPadding
            ),
            editListComponent.textField.bottomAnchor.constraint(
                equalTo: tableView.topAnchor,
                constant: -.smallPadding
            ),
            editListComponent.textField.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -.bigPadding
            )
        ])

        view.addSubview(editListComponent.buttons)
        NSLayoutConstraint.activate([
            buttonsBottomConstraint,
            editListComponent.buttons.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -.buttonsRegularPadding
            )
        ])
    }

    private func bind() {
        notificationCenter.publisher(for: UIResponder.keyboardWillShowNotification)
            .sink { [weak self] notification in
                notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey]
                    .flatMap { $0 as? CGRect }
                    .map { .buttonWithKeyboardPadding + $0.height }
                    .map { [weak self] in self?.setButtonsBottomPadding(to: $0) }
            }
            .store(in: &subscriptions)

        notificationCenter.publisher(for: UIResponder.keyboardWillHideNotification)
            .sink { [weak self] _ in self?.setButtonsBottomPadding(to: .buttonsRegularPadding) }
            .store(in: &subscriptions)

        viewModel.requestsSubject
            .compactMap { request -> List? in
                guard case .remove(let list) = request else { return nil }
                return list
            }
            .sink { [weak self] list in self.map {
                $0.removeListSubscription = UIAlertController
                    .presentRemoveListConfirmationSheet(in: $0)
                    .sink { [weak self] _ in self?.viewModel.removeList(list) }
            }}
            .store(in: &subscriptions)

        viewModel.requestsSubject
            .compactMap { request -> List? in
                guard case .changeName(let list) = request else { return nil }
                return list
            }
            .sink { [weak self] list in
                self?.viewModel.lists.firstIndex(of: list).map {
                    self?.tableView.selectRow(at: .init(row: $0, section: 0), animated: true, scrollPosition: .middle)
                }
            }
            .store(in: &subscriptions)

        viewModel.requestsSubject
            .compactMap { request -> List? in
                guard case .openItems(let list) = request else { return nil }
                return list
            }
            .sink { [weak self] list in
                self.map { $0.present($0.factory.itemsViewController(for: list), animated: true) }
            }
            .store(in: &subscriptions)
    }

    private func setButtonsBottomPadding(to padding: CGFloat) {
        buttonsBottomConstraint.constant = -padding

        UIView.animate(withDuration: 0) {
            self.view.layoutIfNeeded()
        }
    }
}

private extension CGFloat {
    static let buttonsRegularPadding: CGFloat = 40
    static let buttonWithKeyboardPadding: CGFloat = 16

    static let smallPadding: CGFloat = 8
    static let bigPadding: CGFloat = 16
}
