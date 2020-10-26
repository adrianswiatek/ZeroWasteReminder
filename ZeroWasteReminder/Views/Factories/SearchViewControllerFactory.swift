import UIKit

public final class SearchViewControllerFactory {
    private let viewModel: SearchViewModel

    public init(viewModel: SearchViewModel) {
        self.viewModel = viewModel
    }

    public func create() -> UIViewController {
        SearchNavigationController(
            rootViewController: SearchViewController(viewModel: viewModel)
        )
    }
}
