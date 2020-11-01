import UIKit

public final class ListsViewControllerFactory {
    private let viewModel: ListsViewModel
    private let notificationCenter: NotificationCenter
    private let listsCoordinator: ListsCoordinator

    public init(
        viewModel: ListsViewModel,
        notificationCenter: NotificationCenter,
        listsCoordinator: ListsCoordinator
    ) {
        self.viewModel = viewModel
        self.notificationCenter = notificationCenter
        self.listsCoordinator = listsCoordinator
    }

    public func create() -> UIViewController {
        ListsNavigationController(rootViewController: ListsViewController(
            viewModel: viewModel,
            coordinator: listsCoordinator,
            notificationCenter: notificationCenter
        ))
    }
}
