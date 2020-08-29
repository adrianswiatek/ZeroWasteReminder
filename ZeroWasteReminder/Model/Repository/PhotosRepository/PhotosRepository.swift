import Combine
import Foundation

public protocol PhotosRepository {
    @discardableResult
    func fetchThumbnails(for item: Item) -> Future<[Photo], AppError>

    @discardableResult
    func fetchFullSize(with photoId: Id<Photo>) -> Future<Photo, AppError>

    @discardableResult
    func update(_ photosChangeset: PhotosChangeset, for item: Item) -> Future<Void, Never>
}

public extension PhotosRepository {
    func nextId() -> Id<Photo> {
        .fromUuid(.init())
    }
}
