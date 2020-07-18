import Combine
import UIKit

public final class PhotosViewModel {
    private let thumbnailsSubject: CurrentValueSubject<[Photo], Never>
    public var thumbnails: AnyPublisher<[Photo], Never> {
        thumbnailsSubject.eraseToAnyPublisher()
    }

    private let isLoadingOverlayVisibleSubject: CurrentValueSubject<Bool, Never>
    public var isLoadingOverlayVisible: AnyPublisher<Bool, Never> {
        isLoadingOverlayVisibleSubject.eraseToAnyPublisher()
    }

    private let needsCaptureImageSubject: PassthroughSubject<PhotoCaptureTarget, Never>
    public var needsCaptureImage: AnyPublisher<PhotoCaptureTarget, Never> {
        needsCaptureImageSubject.eraseToAnyPublisher()
    }

    private let needsShowImageSubject: PassthroughSubject<UIImage, Never>
    public var needsShowImage: AnyPublisher<UIImage, Never> {
        needsShowImageSubject.eraseToAnyPublisher()
    }

    private let needsRemoveImageSubject: PassthroughSubject<Int, Never>
    public var needsRemoveImage: AnyPublisher<Int, Never> {
        needsRemoveImageSubject.eraseToAnyPublisher()
    }

    public private(set) var photosChangeset: PhotosChangeset

    private let photosRepository: PhotosRepository
    private let itemsService: ItemsService
    private let fileService: FileService

    private var subscriptions: Set<AnyCancellable>
    private var fetchPhotosSubscription: AnyCancellable?
    private var downsizeImageSubscription: AnyCancellable?

    public init(photosRepository: PhotosRepository, itemsService: ItemsService, fileService: FileService) {
        self.photosRepository = photosRepository
        self.itemsService = itemsService
        self.fileService = fileService

        self.photosChangeset = .init()

        self.thumbnailsSubject = .init([])
        self.isLoadingOverlayVisibleSubject = .init(false)
        self.needsCaptureImageSubject = .init()
        self.needsShowImageSubject = .init()
        self.needsRemoveImageSubject = .init()

        self.downsizeImageSubscription = nil
        self.subscriptions = []
    }

    public func fetchThumbnails(for item: Item) {
        isLoadingOverlayVisibleSubject.value = true

        fetchPhotosSubscription = photosRepository.fetchThumbnails(for: item)
            .sink(
                receiveCompletion: { [weak self] _ in self?.fetchPhotosSubscription?.cancel() },
                receiveValue: { [weak self] in
                    self?.thumbnailsSubject.value = $0
                    self?.isLoadingOverlayVisibleSubject.value = false
                }
            )
    }

    public func addImage(at url: URL) {
        DispatchQueue.main.async {
            self.makePhotosToSave(at: url).map { self.addPhoto($0) }
        }
    }

    public func addImage(_ image: UIImage) {
        downsizeImageSubscription = fileService.saveTemporaryImage(image)
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .compactMap { [weak self] in self?.makePhotosToSave(at: $0) }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] in self?.addPhoto($0) }
            )
    }

    public func deleteImage(at index: Int) {
        precondition(0 ..< thumbnailsSubject.value.count ~= index, "Index out of bounds.")
        let photo = thumbnailsSubject.value.remove(at: index)
        photosChangeset = photosChangeset.withDeletedPhoto(id: photo.id)
    }

    public func setNeedsCaptureImage(target: PhotoCaptureTarget) {
        needsCaptureImageSubject.send(target)
    }

    public func setNeedsShowImage(at index: Int) {
        precondition(0 ..< thumbnailsSubject.value.count ~= index, "Index out of bounds.")

        let photoId = thumbnailsSubject.value[index].id
        if let photo = photosChangeset.photosToSave.first(where: { $0.id == photoId }) {
            needsShowImageSubject.send(photo.fullSize.asImage())
        } else {
            fetchFullSizePhoto(with: photoId)
        }
    }

    public func setNeedsRemoveImage(at index: Int) {
        precondition(0 ..< thumbnailsSubject.value.count ~= index, "Index out of bounds.")
        needsRemoveImageSubject.send(index)
    }

    private func addPhoto(_ photo: PhotoToSave) {
        thumbnailsSubject.value.insert(photo.thumbnail, at: 0)
        photosChangeset = photosChangeset.withSavedPhoto(photo)
    }

    private func makePhotosToSave(at url: URL) -> PhotoToSave? {
        guard
            let fullSizeImage = downsizeImage(at: url, for: .fullSize),
            let thumbnailImage = downsizeImage(at: url, for: .thumbnail)
        else { return nil }

        return .init(fullSizeImage: fullSizeImage, thumbnailImage: thumbnailImage)
    }

    private func downsizeImage(at url: URL, for size: PhotoSize) -> UIImage? {
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceThumbnailMaxPixelSize: size.rawValue
        ]

        return CGImageSourceCreateWithURL(url as CFURL, nil)
            .flatMap { CGImageSourceCreateThumbnailAtIndex($0, 0, options as CFDictionary) }
            .map { UIImage(cgImage: $0) }
    }

    private func fetchFullSizePhoto(with photoId: UUID) {
        photosRepository.fetchFullSize(with: photoId)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] in self?.needsShowImageSubject.send($0.asImage()) }
            )
            .store(in: &subscriptions)
    }
}

private extension PhotosViewModel {
    enum PhotoSize: Int {
        case fullSize = 750
        case thumbnail = 250
    }
}
