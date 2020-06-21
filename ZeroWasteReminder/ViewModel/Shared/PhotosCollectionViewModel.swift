import Combine
import UIKit

public final class PhotosCollectionViewModel {
    private let thumbnailsSubject: CurrentValueSubject<[Photo], Never>
    public var thumbnails: AnyPublisher<[Photo], Never> {
        thumbnailsSubject.eraseToAnyPublisher()
    }

    private let isLoadingOverlayVisibleSubject: CurrentValueSubject<Bool, Never>
    public var isLoadingOverlayVisible: AnyPublisher<Bool, Never> {
        isLoadingOverlayVisibleSubject.eraseToAnyPublisher()
    }

    private let needsCaptureImageSubject: PassthroughSubject<Void, Never>
    public var needsCaptureImage: AnyPublisher<Void, Never> {
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

    private let fileService: FileService
    private let itemsService: ItemsService

    private var subscriptions: Set<AnyCancellable>
    private var fetchPhotosSubscription: AnyCancellable?
    private var downsizeImageSubscription: AnyCancellable?

    public init(itemsService: ItemsService, fileService: FileService) {
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

    public func fetchThumbnails(forItem item: Item) {
        isLoadingOverlayVisibleSubject.value = true

        fetchPhotosSubscription = itemsService.fetchThumbnails(forItem: item)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] in
                    self?.thumbnailsSubject.value = $0
                    self?.isLoadingOverlayVisibleSubject.value = false
                }
            )
    }

    public func addImage(atUrl url: URL) {
        DispatchQueue.main.async {
            self.makePhotoWithThumbnail(atUrl: url).map { self.addPhoto($0) }
        }
    }

    public func addImage(_ image: UIImage) {
        downsizeImageSubscription = fileService.saveTemporaryImage(image)
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .compactMap { [weak self] in self?.makePhotoWithThumbnail(atUrl: $0) }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] in self?.addPhoto($0) }
        )
    }

    public func deleteImage(atIndex index: Int) {
        precondition(0 ..< thumbnailsSubject.value.count ~= index, "Index out of bounds.")
        let photo = thumbnailsSubject.value.remove(at: index)
        photosChangeset = photosChangeset.withDeletedPhoto(id: photo.parentId!)
    }

    public func setNeedsCaptureImage() {
        needsCaptureImageSubject.send()
    }

    public func setNeedsShowImage(atIndex index: Int) {
        precondition(0 ..< thumbnailsSubject.value.count ~= index, "Index out of bounds.")

        guard let id = thumbnailsSubject.value[index].parentId else {
            preconditionFailure("Thumbnail at given index has not been found.")
        }

        if let photo = photosChangeset.photosToSave.first(where: { $0.id == id }) {
            needsShowImageSubject.send(photo.fullSize.asImage())
        } else {
            fetchFullSizePhoto(withId: id)
        }
    }

    public func setNeedsRemoveImage(atIndex index: Int) {
        precondition(0 ..< thumbnailsSubject.value.count ~= index, "Index out of bounds.")
        needsRemoveImageSubject.send(index)
    }

    private func addPhoto(_ photo: PhotoWithThumbnail) {
        thumbnailsSubject.value.insert(photo.thumbnail, at: 0)
        photosChangeset = photosChangeset.withSavedPhoto(photo)
    }

    private func makePhotoWithThumbnail(atUrl url: URL) -> PhotoWithThumbnail? {
        guard
            let fullSize = downsizeImage(atUrl: url, forSize: .fullSize),
            let thumbnail = downsizeImage(atUrl: url, forSize: .thumbnail)
        else { return nil }

        return .init(fullSize: Photo(image: fullSize), thumbnail: Photo(image: thumbnail))
    }

    private func downsizeImage(atUrl url: URL, forSize size: PhotoSize) -> UIImage? {
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

    private func fetchFullSizePhoto(withId id: UUID) {
        itemsService.fetchFullSizePhoto(withId: id)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] in self?.needsShowImageSubject.send($0.asImage()) }
            )
            .store(in: &subscriptions)
    }
}

private extension PhotosCollectionViewModel {
    enum PhotoSize: Int {
        case fullSize = 750
        case thumbnail = 250
    }
}
