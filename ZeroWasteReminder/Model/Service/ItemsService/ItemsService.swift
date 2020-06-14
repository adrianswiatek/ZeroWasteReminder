import Combine

public protocol ItemsService {
    var items: AnyPublisher<[Item], Never> { get }

    @discardableResult
    func add(_ item: Item) -> Future<Void, ServiceError>

    @discardableResult
    func refresh() -> Future<Void, ServiceError>

    @discardableResult
    func update(_ item: Item) -> Future<Void, ServiceError>

    @discardableResult
    func updatePhotos(_ photosChangeset: PhotosChangeset, forItem item: Item) -> Future<Void, ServiceError>

    @discardableResult
    func delete(_ items: [Item]) -> Future<Void, ServiceError>

    @discardableResult
    func deleteAll() -> Future<Void, ServiceError>

    @discardableResult
    func fetchPhotos(forItem item: Item) -> Future<[Photo], ServiceError>
}
