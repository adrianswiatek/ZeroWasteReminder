import UIKit

public struct PhotoToSave: Hashable {
    private let data: Data
    private let image: UIImage

    public init(image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 1) else {
            preconditionFailure("Cannot create Photo object.")
        }

        self.data = data
        self.image = image
    }

    public func asImage() -> UIImage {
        image
    }

    public func asData() -> Data {
        data
    }
}

public struct ConnectedPhoto: Hashable {
    public let parentId: UUID

    private let data: Data
    private let image: UIImage

    public init(parentId: UUID, data: Data) {
        guard let image = UIImage(data: data) else {
            preconditionFailure("Cannot create Photo object.")
        }

        self.data = data
        self.image = image
        self.parentId = parentId
    }

    public init(image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 1) else {
            preconditionFailure("Cannot create Photo object.")
        }

        self.data = data
        self.image = image
        self.parentId = .empty
    }

    public func withParentId(_ id: UUID) -> ConnectedPhoto {
        .init(parentId: id, data: data)
    }

    public func asImage() -> UIImage {
        image
    }

    public func asData() -> Data {
        data
    }
}
