public struct PhotosChangeset {
    public let toSave: [Photo]
    public let toDelete: [Photo]

    public init() {
        self.init(toSave: [], toDelete: [])
    }

    private init(toSave: [Photo], toDelete: [Photo]) {
        self.toSave = toSave
        self.toDelete = toDelete
    }

    public func withSavedPhoto(_ photo: Photo) -> PhotosChangeset {
        guard !toSave.contains(photo) else { return self }
        return .init(toSave: toSave + [photo], toDelete: toDelete)
    }

    public func withDeletedPhoto(_ photo: Photo) -> PhotosChangeset {
        guard !toDelete.contains(photo) else { return self }

        if toSave.contains(photo) {
            return .init(toSave: toSave.filter { $0.id != photo.id }, toDelete: toDelete)
        }

        return .init(toSave: toSave, toDelete: toDelete + [photo])
    }
}
