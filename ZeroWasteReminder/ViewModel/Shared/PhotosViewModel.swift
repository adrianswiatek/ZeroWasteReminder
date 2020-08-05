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

    public let requestSubject: PassthroughSubject<Request, Never>
    public private(set) var photosChangeset: PhotosChangeset

    private let photosRepository: PhotosRepository
    private let fileService: FileService

    private var subscriptions: Set<AnyCancellable>
    private var fetchPhotosSubscription: AnyCancellable?
    private var downsizeImageSubscription: AnyCancellable?

    public init(photosRepository: PhotosRepository, fileService: FileService) {
        self.photosRepository = photosRepository
        self.fileService = fileService

        self.requestSubject = .init()
        self.photosChangeset = .init()

        self.thumbnailsSubject = .init([])
        self.isLoadingOverlayVisibleSubject = .init(false)

        self.downsizeImageSubscription = nil
        self.subscriptions = []

        self.bind()
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

    public func deletePhoto(_ photo: Photo) {
        thumbnailsSubject.value.firstIndex(of: photo).map {
            thumbnailsSubject.value.remove(at: $0)
            photosChangeset = photosChangeset.withDeletedPhoto(id: photo.id)
        }
    }

    public func thumbnail(at index: Int) -> Photo {
        precondition(0 ..< thumbnailsSubject.value.count ~= index, "Index out of bounds.")
        return thumbnailsSubject.value[index]
    }

//    public func setNeedsRemoveImage(at index: Int) {
//        precondition(0 ..< thumbnailsSubject.value.count ~= index, "Index out of bounds.")
//        needsRemoveImageSubject.send(index)
//    }

    private func bind() {
        requestSubject
            .compactMap { [weak self] in
                guard let self = self, case .showPhotoAt(let index) = $0 else { return nil }
                precondition(0 ..< self.thumbnailsSubject.value.count ~= index, "Index out of bounds.")
                return index
            }
            .sink { [weak self] in self?.sendShowPhotoRequest(at: $0) }
            .store(in: &subscriptions)
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

        return .init(
            id: photosRepository.nextId(),
            fullSizeImage: fullSizeImage,
            thumbnailImage: thumbnailImage
        )
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

    private func sendShowPhotoRequest(at index: Int) {
        precondition(0 ..< thumbnailsSubject.value.count ~= index, "Index out of bounds.")

        let photoId = thumbnailsSubject.value[index].id

        if let photo = photosChangeset.photosToSave.first(where: { $0.id == photoId }) {
            return requestSubject.send(.showPhoto(photo.fullSize))
        }

        photosRepository.fetchFullSize(with: photoId)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] in self?.requestSubject.send(.showPhoto($0)) }
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

public extension PhotosViewModel {
    enum Request: Equatable {
        case capturePhoto(target: PhotoCaptureTarget)
        case removePhoto(_ photo: Photo)
        case showPhoto(_ photo: Photo)
        case showPhotoAt(index: Int)
    }
}
