import UIKit

public final class ListsViewControllerFactory {
    private let viewModelFactory: ListsViewModelFactory
    private let notificationCenter: NotificationCenter
    private let coordinator: ListsCoordinator

    public init(
        viewModelFactory: ListsViewModelFactory,
        notificationCenter: NotificationCenter,
        coordinator: ListsCoordinator
    ) {
        self.viewModelFactory = viewModelFactory
        self.notificationCenter = notificationCenter
        self.coordinator = coordinator
    }

    public func create() -> UIViewController {
        ListsNavigationController(rootViewController: ListsViewController(
            viewModel: viewModelFactory.create(),
            coordinator: coordinator,
            notificationCenter: notificationCenter
        ))
    }
}
