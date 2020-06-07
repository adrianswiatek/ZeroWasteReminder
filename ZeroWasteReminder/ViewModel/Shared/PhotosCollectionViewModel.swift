import Combine
import UIKit

public final class PhotosCollectionViewModel {
    private let photosSubject: CurrentValueSubject<[UIImage], Never>
    public var photos: AnyPublisher<[UIImage], Never> {
        photosSubject.eraseToAnyPublisher()
    }

    private let needsCapturePhotoSubject: PassthroughSubject<Void, Never>
    public var needsCapturePhoto: AnyPublisher<Void, Never> {
        needsCapturePhotoSubject.eraseToAnyPublisher()
    }

    private let needsShowPhotoSubject: PassthroughSubject<UIImage, Never>
    public var needsShowPhoto: AnyPublisher<UIImage, Never> {
        needsShowPhotoSubject.eraseToAnyPublisher()
    }

    private let needsRemovePhotoSubject: PassthroughSubject<Int, Never>
    public var needsRemovePhoto: AnyPublisher<Int, Never> {
        needsRemovePhotoSubject.eraseToAnyPublisher()
    }

    private init(_ photos: [UIImage]) {
        photosSubject = .init(photos)
        needsCapturePhotoSubject = .init()
        needsShowPhotoSubject = .init()
        needsRemovePhotoSubject = .init()
    }

    public static func withPhotos(_ photos: [Photo]) -> Self {
        .init(photos.compactMap { UIImage(data: $0.data) })
    }

    public static func withoutPhotos() -> Self {
        .init([])
    }

    public func addPhotoAtUrl(_ photoUrl: URL) {
        guard let photo = downsizeImageAtUrl(photoUrl) else { return }
        photosSubject.value.insert(photo, at: 0)
    }

    public func removePhoto(atIndex index: Int) {
        precondition(0 ..< photosSubject.value.count ~= index, "Index out of bounds.")
        photosSubject.value.remove(at: index)
    }

    public func setNeedsCapturePhoto() {
        needsCapturePhotoSubject.send()
    }

    public func setNeedsShowPhoto(atIndex index: Int) {
        precondition(0 ..< photosSubject.value.count ~= index, "Index out of bounds.")
        needsShowPhotoSubject.send(photosSubject.value[index])
    }

    public func setNeedsRemovePhoto(atIndex index: Int) {
        precondition(0 ..< photosSubject.value.count ~= index, "Index out of bounds.")
        needsRemovePhotoSubject.send(index)
    }

    public func createPhotos() -> [Photo] {
        photosSubject.value.compactMap { $0.pngData() }.map { Photo(data: $0) }
    }

    private func downsizeImageAtUrl(_ imageUrl: URL) -> UIImage? {
        guard let imageSource = CGImageSourceCreateWithURL(imageUrl as CFURL, nil) else {
            assertionFailure("Cannot create image source.")
            return nil
        }

        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceThumbnailMaxPixelSize: 500
        ]

        guard let thumbnail = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary) else {
            assertionFailure("Cannot create thumbnail.")
            return nil
        }

        return UIImage(cgImage: thumbnail)
    }
}
