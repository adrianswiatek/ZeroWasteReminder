import UIKit

public struct Photo: Hashable {
    public let id: UUID

    private let data: Data
    private let image: UIImage

    public init(parentId: UUID, data: Data) {
        guard let image = UIImage(data: data) else {
            preconditionFailure("Cannot create Photo object.")
        }

        self.data = data
        self.image = image
        self.id = parentId
    }

    public func asImage() -> UIImage {
        image
    }

    public func asData() -> Data {
        data
    }
}
