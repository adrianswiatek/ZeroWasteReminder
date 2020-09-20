import Combine
import Foundation

public final class InMemoryPhotosRepository: PhotosRepository {
    private var itemIdsToPhotos: [Id<Item>: [PhotoToSave]] = [:]

    private var photos: [PhotoToSave] {
        itemIdsToPhotos.reduce(into: [PhotoToSave]()) { $0 += $1.value }
    }

    private let eventDispatcher: EventDispatcher

    public init(eventDispatcher: EventDispatcher) {
        self.eventDispatcher = eventDispatcher
    }

    public func fetchThumbnails(for item: Item) -> Future<[Photo], AppError> {
        Future { [weak self] promise in
            let thumbnails = self?.itemIdsToPhotos[item.id]?.map { $0.thumbnail }
            promise(.success(thumbnails ?? []))
        }
    }

    public func fetchFullSize(with photoId: Id<Photo>) -> Future<Photo, AppError> {
        Future { [weak self] promise in
            guard let photo = self?.photos.first(where: { $0.id == photoId }) else {
                return promise(.failure(.general("Photo with given id does not exist.")))
            }

            promise(.success(photo.fullSize))
        }
    }

    public func update(_ photosChangeset: PhotosChangeset, for item: Item) {
        guard photosChangeset.hasChanges else {
            return eventDispatcher.dispatch(NoResultOccured())
        }

        itemIdsToPhotos.updateValue(photosChangeset.photosToSave, forKey: item.id)
        itemIdsToPhotos[item.id]?.removeAll { photosChangeset.idsToDelete.contains($0.id) }

        eventDispatcher.dispatch(PhotosUpdated(item.id))
    }
}
