import UIKit

public struct PhotoToSave: Hashable{
    public let id: Id<Photo>
    public let fullSize: Photo
    public let thumbnail: Photo

    public init(id: Id<Photo>, fullSizeImage: UIImage, thumbnailImage: UIImage) {
        self.id = id
        self.fullSize = .init(id: id, image: fullSizeImage)
        self.thumbnail = .init(id: id, image: thumbnailImage)
    }
}
