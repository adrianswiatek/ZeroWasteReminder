import UIKit

public final class SearchViewControllerFactory {
    private let viewModel: SearchViewModel
    private let coordinator: SearchCoordinator

    public init(viewModel: SearchViewModel, coordinator: SearchCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator
    }

    public func create() -> UIViewController {
        SearchNavigationController(rootViewController: SearchViewController(
            viewModel: viewModel,
            coordinator: coordinator
        ))
    }
}
