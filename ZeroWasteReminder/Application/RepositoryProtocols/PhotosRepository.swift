import Combine
import Foundation

public protocol PhotosRepository {
    func fetchThumbnails(for item: Item) -> Future<[Photo], AppError>
    func fetchFullSize(with photoId: Id<Photo>) -> Future<Photo, AppError>
    func update(_ photosChangeset: PhotosChangeset, for item: Item)
}

public extension PhotosRepository {
    func nextId() -> Id<Photo> {
        .fromUuid(.init())
    }
}
