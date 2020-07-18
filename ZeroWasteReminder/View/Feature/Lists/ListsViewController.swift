import Combine
import UIKit

public final class ListsViewController: UIViewController {
    private let tableView: ListsTableView
    private let dataSource: ListsDataSource

    private let editListComponent: EditListComponent

    private let viewModel: ListsViewModel
    private let notificationCenter: NotificationCenter

    private var removeListSubscription: AnyCancellable?
    private var subscriptions: Set<AnyCancellable>

    private lazy var buttonsBottomConstraint: NSLayoutConstraint =
        editListComponent.buttons.bottomAnchor.constraint(
            equalTo: view.bottomAnchor,
            constant: -Metrics.buttonsRegularPadding
        )

    public init(viewModel: ListsViewModel, notificationCenter: NotificationCenter) {
        self.viewModel = viewModel
        self.notificationCenter = notificationCenter

        self.tableView = .init(viewModel: viewModel)
        self.dataSource = .init(tableView, viewModel)

        self.editListComponent = .init(viewModel: viewModel)

        self.subscriptions = []

        super.init(nibName: nil, bundle: nil)

        self.setupView()
        self.bind()
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
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -24),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
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
            editListComponent.textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            editListComponent.textField.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: 16
            ),
            editListComponent.textField.bottomAnchor.constraint(equalTo: tableView.topAnchor, constant: -8),
            editListComponent.textField.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -16
            ),
        ])

        view.addSubview(editListComponent.buttons)
        NSLayoutConstraint.activate([
            buttonsBottomConstraint,
            editListComponent.buttons.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -Metrics.buttonsRegularPadding
            )
        ])
    }

    private func bind() {
        notificationCenter.publisher(for: UIResponder.keyboardWillShowNotification)
            .sink { [weak self] notification in
                notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey]
                    .flatMap { $0 as? CGRect }
                    .map { Metrics.buttonWithKeyboardPadding + $0.height }
                    .map { [weak self] in self?.setButtonsBottomPadding(to: $0) }
            }
            .store(in: &subscriptions)

        notificationCenter.publisher(for: UIResponder.keyboardWillHideNotification)
            .sink { [weak self] _ in self?.setButtonsBottomPadding(to: Metrics.buttonsRegularPadding) }
            .store(in: &subscriptions)

        viewModel.needsRemoveList
            .sink { [weak self] list in
                guard let self = self else { return }
                self.removeListSubscription = UIAlertController
                    .presentRemoveListConfirmationSheet(in: self)
                    .sink { [weak self] _ in self?.viewModel.removeList(list) }
            }
            .store(in: &subscriptions)

        viewModel.needsChangeNameForList
            .sink { [weak self] list, index in
                self?.tableView.selectRow(at: .init(row: index, section: 0), animated: true, scrollPosition: .middle)
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

private extension ListsViewController {
    enum Metrics {
        static let buttonsRegularPadding: CGFloat = 40
        static let buttonWithKeyboardPadding: CGFloat = 16
    }
}
