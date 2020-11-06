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

    public func fetchThumbnail(with id: Id<Photo>) -> Future<Photo?, Never> {
        Future { [weak self] promise in
            let photo = self?.itemIdsToPhotos.values
                .flatMap { $0 }
                .map { $0.thumbnail }
                .first { $0.id == id }

            promise(.success(photo))
        }
    }

    public func fetchThumbnails(for item: Item) -> Future<[Photo], Never> {
        Future { [weak self] promise in
            let thumbnails = self?.itemIdsToPhotos[item.id]?.map { $0.thumbnail }
            promise(.success(thumbnails ?? []))
        }
    }

    public func fetchFullSize(with id: Id<Photo>) -> Future<Photo?, Never> {
        Future { [weak self] promise in
            promise(.success(self?.photos.first(where: { $0.id == id })?.fullSize))
        }
    }

    public func update(_ photosChangeset: PhotosChangeset, for item: Item) {
        guard photosChangeset.hasChanges else {
            return eventDispatcher.dispatch(NoResultOccured())
        }

        let existingPhotos = itemIdsToPhotos[item.id] ?? []
        itemIdsToPhotos.updateValue(existingPhotos + photosChangeset.photosToSave, forKey: item.id)
        itemIdsToPhotos[item.id]?.removeAll { photosChangeset.idsToDelete.contains($0.id) }

        eventDispatcher.dispatch(PhotosUpdated(item.id))
    }
}
