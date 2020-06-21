import Combine
import Foundation

public protocol PhotosService {
    @discardableResult
    func fetchThumbnails(forItem item: Item) -> Future<[Photo], ServiceError>

    @discardableResult
    func fetchFullSize(withId photoId: UUID) -> Future<Photo, ServiceError>

    @discardableResult
    func update(_ photosChangeset: PhotosChangeset, forItem item: Item) -> Future<Void, ServiceError>
}
