import Combine
import Foundation

public final class InMemoryPhotosService: PhotosService {
    public func fetchThumbnails(forItemId itemId: UUID) -> Future<[Photo], ServiceError> {
        Future { promise in }
    }

    public func fetchFullSize(withId photoId: UUID) -> Future<Photo, ServiceError> {
        Future { promise in }
    }

    public func update(
        _ photosChangeset: PhotosChangeset,
        forItemId itemId: UUID
    ) -> Future<Void, ServiceError> {
        Future { promise in }
    }
}
