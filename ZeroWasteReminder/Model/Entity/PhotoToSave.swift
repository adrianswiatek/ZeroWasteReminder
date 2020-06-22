import UIKit

public struct PhotoToSave: Hashable{
    public let id: UUID
    public let fullSize: Photo
    public let thumbnail: Photo

    public init(fullSizeImage: UIImage, thumbnailImage: UIImage) {
        self.id = UUID()
        self.fullSize = .init(id: id, image: fullSizeImage)
        self.thumbnail = .init(id: id, image: thumbnailImage)
    }
}
