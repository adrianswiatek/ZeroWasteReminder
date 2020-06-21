import UIKit

public struct Photo: Hashable {
    public let parentId: UUID?

    private let data: Data
    private let image: UIImage

    public init(data: Data) {
        guard let image = UIImage(data: data) else {
            preconditionFailure("Cannot create Photo object.")
        }

        self.data = data
        self.image = image
        self.parentId = nil
    }

    public init(image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 1) else {
            preconditionFailure("Cannot create Photo object.")
        }

        self.data = data
        self.image = image
        self.parentId = nil
    }

    private init(parentId: UUID, data: Data) {
        guard let image = UIImage(data: data) else {
            preconditionFailure("Cannot create Photo object.")
        }

        self.data = data
        self.image = image
        self.parentId = parentId
    }

    public func withParentId(_ id: UUID) -> Photo {
        .init(parentId: id, data: data)
    }

    public func asImage() -> UIImage {
        image
    }

    public func asData() -> Data {
        data
    }
}
