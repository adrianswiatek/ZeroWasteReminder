import Combine
import Foundation

public protocol PhotosRepository {
    @discardableResult
    func fetchThumbnails(for item: Item) -> Future<[Photo], ServiceError>

    @discardableResult
    func fetchFullSize(with photoId: Id<Photo>) -> Future<Photo, ServiceError>

    @discardableResult
    func update(_ photosChangeset: PhotosChangeset, for item: Item) -> Future<Void, ServiceError>
}

public extension PhotosRepository {
    func nextId() -> Id<Photo> {
        .fromUuid(.init())
    }
}
