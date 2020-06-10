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

    private let fileService: FileService
    private let itemsService: ItemsService

    private var subscriptions: Set<AnyCancellable>
    private var fetchPhotosSubscription: AnyCancellable?
    private var downsizeImageSubscription: AnyCancellable?

    public init(itemsService: ItemsService, fileService: FileService) {
        self.itemsService = itemsService
        self.fileService = fileService

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

    public func addImage(atUrl url: URL) {
        DispatchQueue.main.async {
            guard let image = self.downsizeImage(atUrl: url) else { return }
            self.photosSubject.value.insert(.init(image: image), at: 0)
        }
    }

    public func addImage(_ image: UIImage) {
        downsizeImageSubscription = fileService.saveTemporaryImage(image)
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .compactMap { [weak self] in self?.downsizeImage(atUrl: $0) }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] in self?.photosSubject.value.insert(.init(image: $0), at: 0) }
            )
    }

    public func removeImage(atIndex index: Int) {
        precondition(0 ..< photosSubject.value.count ~= index, "Index out of bounds.")
        photosSubject.value.remove(at: index)
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

    public func createPhotos() -> [Photo] {
        photosSubject.value
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
