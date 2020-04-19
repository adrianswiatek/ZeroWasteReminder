import UIKit

public final class ViewControllerFactory {
    private let itemsService: ItemsService

    public init(itemsService: ItemsService) {
        self.itemsService = itemsService
    }

    public var listViewController: UIViewController {
        let viewController = ListViewController(factory: self)
        return ListNavigationController(rootViewController: viewController)
    }

    public var addViewController: UIViewController {
        let viewModel = AddViewModel(itemsService: itemsService)
        let viewController = AddViewController(viewModel: viewModel)
        return AddNavigationController(rootViewController: viewController)
    }
}
