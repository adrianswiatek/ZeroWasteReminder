import Combine
import UIKit

public final class PhotosCollectionViewModel {
    private let photosSubject: CurrentValueSubject<[Photo], Never>
    public var photos: AnyPublisher<[Photo], Never> {
        photosSubject.eraseToAnyPublisher()
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

        self.photosSubject = .init([])
        self.isLoadingOverlayVisibleSubject = .init(false)
        self.needsCaptureImageSubject = .init()
        self.needsShowImageSubject = .init()
        self.needsRemoveImageSubject = .init()

        self.downsizeImageSubscription = nil
        self.subscriptions = []
    }

    public func fetchPhotos(forItem item: Item) {
        isLoadingOverlayVisibleSubject.value = true

        fetchPhotosSubscription = itemsService.fetchPhotos(forItem: item)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] in
                    self?.photosSubject.value = $0
                    self?.isLoadingOverlayVisibleSubject.value = false
                }
            )
    }

    public func createPhotos() -> [Photo] {
        photosSubject.value
    }

    public func addImage(atUrl url: URL) {
        DispatchQueue.main.async {
            guard let image = self.downsizeImage(atUrl: url) else { return }
            self.addPhoto(.init(image: image))
        }
    }

    public func addImage(_ image: UIImage) {
        downsizeImageSubscription = fileService.saveTemporaryImage(image)
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .compactMap { [weak self] in self?.downsizeImage(atUrl: $0) }
            .map { Photo(image: $0) }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] in self?.addPhoto($0) }
        )
    }

    public func deleteImage(atIndex index: Int) {
        precondition(0 ..< photosSubject.value.count ~= index, "Index out of bounds.")
        let photo = photosSubject.value.remove(at: index)
        photosChangeset = photosChangeset.withDeletedPhoto(photo)
    }

    public func setNeedsCaptureImage() {
        needsCaptureImageSubject.send()
    }

    public func setNeedsShowImage(atIndex index: Int) {
        precondition(0 ..< photosSubject.value.count ~= index, "Index out of bounds.")
        needsShowImageSubject.send(photosSubject.value[index].asImage())
    }

    public func setNeedsRemoveImage(atIndex index: Int) {
        precondition(0 ..< photosSubject.value.count ~= index, "Index out of bounds.")
        needsRemoveImageSubject.send(index)
    }

    private func addPhoto(_ photo: Photo) {
        photosSubject.value.insert(photo, at: 0)
        photosChangeset = photosChangeset.withSavedPhoto(photo)
    }

    private func downsizeImage(atUrl url: URL) -> UIImage? {
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceThumbnailMaxPixelSize: 500
        ]

        return CGImageSourceCreateWithURL(url as CFURL, nil)
            .flatMap { CGImageSourceCreateThumbnailAtIndex($0, 0, options as CFDictionary) }
            .map { UIImage(cgImage: $0) }
    }
}
