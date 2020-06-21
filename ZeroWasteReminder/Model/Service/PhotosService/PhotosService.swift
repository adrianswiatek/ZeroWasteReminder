import Combine
import Foundation

public protocol PhotosService {
    @discardableResult
    func fetchThumbnails(forItemId itemId: UUID) -> Future<[Photo], ServiceError>

    @discardableResult
    func fetchFullSize(withId photoId: UUID) -> Future<Photo, ServiceError>

    @discardableResult
    func update(_ photosChangeset: PhotosChangeset, forItemId itemId: UUID) -> Future<Void, ServiceError>
}
