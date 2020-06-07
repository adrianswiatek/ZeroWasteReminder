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

    public static func withPhotos(_ photos: [UIImage]) -> Self {
        .init(photos)
    }

    public static func withoutPhotos() -> Self {
        .init([])
    }

    public func addPhoto(_ photo: UIImage) {
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
}
