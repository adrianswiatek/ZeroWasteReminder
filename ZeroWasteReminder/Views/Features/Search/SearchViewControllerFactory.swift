import UIKit

public final class SearchViewControllerFactory {
    private let viewModelFactory: SearchViewModelFactory
    private let coordinator: SearchCoordinator

    public init(viewModelFactory: SearchViewModelFactory, coordinator: SearchCoordinator) {
        self.viewModelFactory = viewModelFactory
        self.coordinator = coordinator
    }

    public func create() -> UIViewController {
        SearchNavigationController(rootViewController: SearchViewController(
            viewModel: viewModelFactory.create(),
            coordinator: coordinator
        ))
    }
}
