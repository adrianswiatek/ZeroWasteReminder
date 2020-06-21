import Combine
import Foundation

public final class InMemoryPhotosService: PhotosService {
    private var photos: [Photo] = []

    public func fetchThumbnails(forItem item: Item) -> Future<[Photo], ServiceError> {
        Future { promise in }
    }

    public func fetchFullSize(withId photoId: UUID) -> Future<Photo, ServiceError> {
        Future { promise in }
    }

    public func update(
        _ photosChangeset: PhotosChangeset,
        forItem item: Item
    ) -> Future<Void, ServiceError> {
        Future { promise in }
    }
}
