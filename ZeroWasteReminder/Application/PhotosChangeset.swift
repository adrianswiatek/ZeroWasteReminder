import Foundation

public struct PhotosChangeset {
    public let photosToSave: [PhotoToSave]
    public let idsToDelete: [Id<Photo>]

    public var hasChanges: Bool {
        !photosToSave.isEmpty || !idsToDelete.isEmpty
    }

    public init() {
        self.init(photosToSave: [], idsToDelete: [])
    }

    private init(photosToSave: [PhotoToSave], idsToDelete: [Id<Photo>]) {
        self.photosToSave = photosToSave
        self.idsToDelete = idsToDelete
    }

    public func withSavedPhoto(_ photo: PhotoToSave) -> PhotosChangeset {
        guard !photosToSave.contains(photo) else { return self }
        return .init(photosToSave: photosToSave + [photo], idsToDelete: idsToDelete)
    }

    public func withRemovedPhoto(id: Id<Photo>) -> PhotosChangeset {
        guard !idsToDelete.contains(id) else { return self }

        if photosToSave.map(\.id).contains(id) {
            return .init(photosToSave: photosToSave.filter { $0.id != id }, idsToDelete: idsToDelete)
        }

        return .init(photosToSave: photosToSave, idsToDelete: idsToDelete + [id])
    }
}
