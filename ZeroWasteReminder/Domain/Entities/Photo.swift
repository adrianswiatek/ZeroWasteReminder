import UIKit

public struct Photo: Hashable {
    public let id: Id<Photo>

    private let data: Data
    private let image: UIImage

    public init(id: Id<Photo>, data: Data) {
        guard let image = UIImage(data: data) else {
            preconditionFailure("Cannot create Photo object.")
        }

        self.id = id
        self.data = data
        self.image = image
    }

    public init(id: Id<Photo>, image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 1) else {
            preconditionFailure("Cannot create Photo object.")
        }

        self.id = id
        self.data = data
        self.image = image
    }

    public var asImage: UIImage {
        image
    }

    public var asData: Data {
        data
    }
}
