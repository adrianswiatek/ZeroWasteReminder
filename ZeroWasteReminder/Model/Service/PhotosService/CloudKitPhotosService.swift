import CloudKit
import Combine
import Foundation

public final class CloudKitPhotosService: PhotosService {
    private let configuration: CloudKitConfiguration
    private let itemsRepository: ItemsRepository

    public init(configuration: CloudKitConfiguration, itemsRepository: ItemsRepository) {
        self.configuration = configuration
        self.itemsRepository = itemsRepository
    }

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
