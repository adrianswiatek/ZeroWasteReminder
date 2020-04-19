import UIKit

public final class ViewControllerFactory {
    public var listViewController: UIViewController {
        let viewController = ListViewController(factory: self)
        return ListNavigationController(rootViewController: viewController)
    }

    public var addViewController: UIViewController {
        let viewModel = AddViewModel()
        let viewController = AddViewController(viewModel: viewModel)
        return AddNavigationController(rootViewController: viewController)
    }
}
