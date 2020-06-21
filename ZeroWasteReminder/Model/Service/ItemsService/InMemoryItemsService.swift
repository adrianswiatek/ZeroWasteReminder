import Combine
import Foundation

public final class InMemoryItemsService: ItemsService {
    private let itemsRepository: ItemsRepository

    public init(itemsRepository: ItemsRepository) {
        self.itemsRepository = itemsRepository
    }

    public func add(_ item: Item) -> Future<Void, ServiceError> {
        Future { [weak self] promise in
            self?.itemsRepository.add(item)
            promise(.success(()))
        }
    }

    public func refresh() -> Future<Void, ServiceError> {
        Future { [weak self] promise in
            self.map { $0.itemsRepository.set($0.itemsRepository.allItems()) }
            promise(.success(()))
        }
    }

    public func update(_ item: Item) -> Future<Void, ServiceError> {
        Future { [weak self] promise in
            self?.itemsRepository.update(item)
            promise(.success(()))
        }
    }

//    public func updatePhotos(_ photosChangeset: PhotosChangeset, forItem item: Item) -> Future<Void, ServiceError> {
//        Future { $0(.success(())) }
//    }

    public func delete(_ items: [Item]) -> Future<Void, ServiceError> {
        Future { [weak self] promise in
            self?.itemsRepository.delete(items)
            promise(.success(()))
        }
    }

    public func deleteAll() -> Future<Void, ServiceError> {
        Future { [weak self] promise in
            self?.itemsRepository.deleteAll()
            promise(.success(()))
        }
    }

//    public func fetchThumbnails(forItem item: Item) -> Future<[Photo], ServiceError> {
//        Future { [weak self] promise in
//            let photos = self?.itemsSubject.value
//                .first { $0.id == item.id }
//                .map { $0.photos.map { $0.thumbnail } }
//
//            promise(.success(photos ?? []))
//        }
//    }
//
//    public func fetchFullSizePhoto(withId id: UUID) -> Future<Photo, ServiceError> {
//        Future { [weak self] promise in
//            let photo = self?.itemsSubject.value.flatMap { $0.photos }.first { $0.id == id }
//
//            if let fullSizePhoto = photo?.fullSize {
//                promise(.success(fullSizePhoto))
//            } else {
//                promise(.failure(.general("Unable to fetch photo.")))
//            }
//        }
//    }
}
