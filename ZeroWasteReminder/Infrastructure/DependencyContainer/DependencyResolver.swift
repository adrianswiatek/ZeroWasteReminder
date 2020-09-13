import Swinject

public protocol DependencyResolver {
    func registerCoordinators()
    func registerEventListeners()
    func registerOtherObjects()
    func registerRepositories()
    func registerServices()
    func registerViewControllerFactories()
    func registerViewModelFactories()
}