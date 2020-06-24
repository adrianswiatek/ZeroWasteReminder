import Combine
import Foundation

public final class InMemoryPhotosService: PhotosService {
    private var itemIdsToPhotos: [UUID: [PhotoToSave]] = [:]

    private var photos: [PhotoToSave] {
        itemIdsToPhotos.reduce(into: [PhotoToSave]()) { $0 += $1.value }
    }

    public func fetchThumbnails(for item: Item) -> Future<[Photo], ServiceError> {
        Future { [weak self] promise in
            let thumbnails = self?.itemIdsToPhotos[item.id]?.map { $0.thumbnail }
            promise(.success(thumbnails ?? []))
        }
    }

    public func fetchFullSize(with photoId: UUID) -> Future<Photo, ServiceError> {
        Future { [weak self] promise in
            guard let photo = self?.photos.first(where: { $0.id == photoId }) else {
                return promise(.failure(.general("Photo with given id does not exist.")))
            }

            promise(.success(photo.fullSize))
        }
    }

    public func update(
        _ photosChangeset: PhotosChangeset,
        for item: Item
    ) -> Future<Void, ServiceError> {
        Future { [weak self] promise in
            guard photosChangeset.hasChanges else { return promise(.success(())) }

            self?.itemIdsToPhotos.updateValue(photosChangeset.photosToSave, forKey: item.id)
            self?.itemIdsToPhotos[item.id]?.removeAll { photosChangeset.idsToDelete.contains($0.id) }

            promise(.success(()))
        }
    }
}
