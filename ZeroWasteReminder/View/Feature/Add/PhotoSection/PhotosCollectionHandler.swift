import Combine
import UIKit

public protocol PhotosCollectionHandler: AnyObject {
    var photos: AnyPublisher<[UIImage], Never> { get }

    func setNeedsCapturePhoto()
    func setNeedsShowPhoto(atIndex index: Int)
    func setNeedsRemovePhoto(atIndex index: Int)
}
