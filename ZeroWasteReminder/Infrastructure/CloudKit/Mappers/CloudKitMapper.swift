import CloudKit

public final class CloudKitMapper {
    private let fileService: FileService

    public init(fileService: FileService) {
        self.fileService = fileService
    }

    internal func map(_ list: List) -> CloudKitListMapper {
        .init(list)
    }

    internal func map(_ item: Item) -> CloudKitItemMapper {
        .init(item)
    }

    internal func map(_ photo: PhotoToSave) -> CloudKitPhotoMapper {
        .init(photo, fileService)
    }

    internal func map(_ record: CKRecord?) -> CloudKitRecordMapper {
        .init(record)
    }
}
