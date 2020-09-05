import UIKit

public final class ListsViewControllerFactory {
    private let viewModelFactory: ListsViewModelFactory
    private let notificationCenter: NotificationCenter
    private let listsCoordinator: ListsCoordinator

    public init(
        viewModelFactory: ListsViewModelFactory,
        notificationCenter: NotificationCenter,
        listsCoordinator: ListsCoordinator
    ) {
        self.viewModelFactory = viewModelFactory
        self.notificationCenter = notificationCenter
        self.listsCoordinator = listsCoordinator
    }

    public func create() -> UIViewController {
        let viewController = ListsViewController(
            viewModel: viewModelFactory.create(),
            coordinator: listsCoordinator,
            notificationCenter: notificationCenter
        )
        return ListsNavigationController(rootViewController: viewController)
    }
}
