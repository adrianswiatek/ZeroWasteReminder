import UIKit

public struct Photo: Hashable {
    public let id: UUID

    private let data: Data
    private let image: UIImage

    public init(id: UUID, data: Data) {
        guard let image = UIImage(data: data) else {
            preconditionFailure("Cannot create Photo object.")
        }

        self.id = id
        self.data = data
        self.image = image
    }

    public init(id: UUID, image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 1) else {
            preconditionFailure("Cannot create Photo object.")
        }

        self.id = id
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
