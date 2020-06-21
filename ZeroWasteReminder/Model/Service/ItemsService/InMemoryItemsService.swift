import Combine
import Foundation

public final class InMemoryItemsService: ItemsService {
    public var items: AnyPublisher<[Item], Never> {
        itemsSubject.eraseToAnyPublisher()
    }

    private let itemsSubject = CurrentValueSubject<[Item], Never>([])

    public func add(_ item: Item) -> Future<Void, ServiceError> {
        Future { [weak self] promise in
            guard let self = self else { return }
            self.itemsSubject.value = self.itemsSubject.value + [item]
            promise(.success(()))
        }
    }

    public func refresh() -> Future<Void, ServiceError> {
        Future { [weak self] promise in
            guard let self = self else { return }
            self.itemsSubject.value = self.itemsSubject.value
            promise(.success(()))
        }
    }

    public func update(_ item: Item) -> Future<Void, ServiceError> {
        Future { [weak self] promise in
            guard
                let self = self,
                let itemsIndex = self.itemsSubject.value.firstIndex(where: { $0.id == item.id })
            else { preconditionFailure("Unable to find index of given item") }

            self.itemsSubject.value[itemsIndex] = item
            promise(.success(()))
        }
    }

    public func updatePhotos(_ photosChangeset: PhotosChangeset, forItem item: Item) -> Future<Void, ServiceError> {
        Future { $0(.success(())) }
    }

    public func delete(_ items: [Item]) -> Future<Void, ServiceError> {
        Future { [weak self] promise in
            self?.itemsSubject.value.removeAll { items.contains($0) }
            promise(.success(()))
        }
    }

    public func deleteAll() -> Future<Void, ServiceError> {
        Future { [weak self] promise in
            self?.itemsSubject.value.removeAll()
            promise(.success(()))
        }
    }

    public func fetchThumbnails(forItem item: Item) -> Future<[Photo], ServiceError> {
        Future { [weak self] promise in
            let photos = self?.itemsSubject.value
                .first { $0.id == item.id }
                .map { $0.photos.map { $0.thumbnail } }

            promise(.success(photos ?? []))
        }
    }

    public func fetchFullSizePhoto(withId id: UUID) -> Future<Photo, ServiceError> {
        Future { [weak self] promise in
            let photo = self?.itemsSubject.value.flatMap { $0.photos }.first { $0.id == id }

            if let fullSizePhoto = photo?.fullSize {
                promise(.success(fullSizePhoto))
            } else {
                promise(.failure(.general("Unable to fetch photo.")))
            }
        }
    }
}
