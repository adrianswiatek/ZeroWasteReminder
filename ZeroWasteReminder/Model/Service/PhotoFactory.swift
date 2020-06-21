import Foundation

public struct PhotoWithThumbnail: Hashable {
    public let id: UUID
    public let fullSize: Photo
    public let thumbnail: Photo
}

public extension PhotoWithThumbnail {
    init(fullSize: Photo, thumbnail: Photo) {
        self.id = UUID()
        self.fullSize = fullSize.withParentId(id)
        self.thumbnail = thumbnail.withParentId(id)
    }
}
