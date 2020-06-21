import Foundation

public struct PhotoToSave: Hashable{
    public let id: UUID
    public let fullSize: Photo
    public let thumbnail: Photo
}

public extension PhotoToSave {
    init(fullSize: NotConnectedPhoto, thumbnail: NotConnectedPhoto) {
        self.id = UUID()
        self.fullSize = .init(parentId: id, data: fullSize.asData())
        self.thumbnail = .init(parentId: id, data: thumbnail.asData())
    }
}
