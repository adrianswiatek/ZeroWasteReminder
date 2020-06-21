import Foundation

public struct PhotosChangeset {
    public let photosToSave: [PhotoWithThumbnail]
    public let idsToDelete: [UUID]

    public init() {
        self.init(photosToSave: [], idsToDelete: [])
    }

    private init(photosToSave: [PhotoWithThumbnail], idsToDelete: [UUID]) {
        self.photosToSave = photosToSave
        self.idsToDelete = idsToDelete
    }

    public func withSavedPhoto(_ photo: PhotoWithThumbnail) -> PhotosChangeset {
        guard !photosToSave.contains(photo) else { return self }
        return .init(photosToSave: photosToSave + [photo], idsToDelete: idsToDelete)
    }

    public func withDeletedPhoto(id: UUID) -> PhotosChangeset {
        guard !idsToDelete.contains(id) else { return self }

        if photosToSave.map(\.id).contains(id) {
            return .init(photosToSave: photosToSave.filter { $0.id != id }, idsToDelete: idsToDelete)
        }

        return .init(photosToSave: photosToSave, idsToDelete: idsToDelete + [id])
    }
}
