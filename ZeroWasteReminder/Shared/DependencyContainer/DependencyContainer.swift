import UIKit

internal final class DependencyContainer {
    private let configuration: Configuration
    private let notificationCenter: NotificationCenter

    private let fileService: FileService
    private let moveItemService: MoveItemService
    private let listUpdater: AutomaticListsUpdater

    private let variableDependenciesFactory: VariableDependenciesFactory
    private let viewControllerFactory: ViewControllerFactory

    init(configuration: Configuration, notificationCenter: NotificationCenter = .default) {
        self.configuration = configuration
        self.notificationCenter = notificationCenter

        self.fileService = FileService()

        switch configuration {
        case .inMemory:
            self.variableDependenciesFactory = InMemoryVariableDependenciesFactory()
        case .cloudKit(let containerIdentifier):
            self.variableDependenciesFactory = CloudKitVariableDependenciesFactory(
                containerIdentifier: containerIdentifier,
                fileService: fileService,
                notificationCenter: notificationCenter
            )
        }

        self.moveItemService = MoveItemService(
            listsRepository: variableDependenciesFactory.listsRepository,
            itemsRepository: variableDependenciesFactory.itemsRepository
        )

        self.listUpdater = AutomaticListsUpdater(
            listsRepository: variableDependenciesFactory.listsRepository,
            itemsRepository: variableDependenciesFactory.itemsRepository,
            moveItemService: moveItemService
        )

        self.viewControllerFactory = .init(
            fileService: fileService,
            moveItemService: moveItemService,
            itemsRepository: variableDependenciesFactory.itemsRepository,
            listsRepository: variableDependenciesFactory.listsRepository,
            photosRepository: variableDependenciesFactory.photosRepository,
            listUpdater: listUpdater,
            statusNotifier: variableDependenciesFactory.statusNotifier,
            sharingControllerFactory: variableDependenciesFactory.sharingControllerFactory,
            notificationCenter: notificationCenter
        )

        variableDependenciesFactory.accountService.refreshUserEligibility()
        variableDependenciesFactory.subscriptionService.registerItemsSubscriptionIfNeeded()
    }

    public var rootViewController: UIViewController {
        viewControllerFactory.listsViewController
    }
}

internal extension DependencyContainer {
    enum Configuration {
        case inMemory
        case cloudKit(containerIdentifier: String)
    }
}
