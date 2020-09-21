import Combine
import Foundation

public protocol PhotosRepository {
    func fetchThumbnail(with id: Id<Photo>) -> Future<Photo?, Never>
    func fetchThumbnails(for item: Item) -> Future<[Photo], Never>
    func fetchFullSize(with id: Id<Photo>) -> Future<Photo?, Never>
    func update(_ photosChangeset: PhotosChangeset, for item: Item)
}

public extension PhotosRepository {
    func nextId() -> Id<Photo> {
        .fromUuid(.init())
    }
}
