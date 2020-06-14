import UIKit

public struct Photo: Identifiable, Hashable {
    public let id: UUID

    private let data: Data
    private let image: UIImage

    public init(id: UUID = UUID(), data: Data) {
        guard let image = UIImage(data: data) else {
            preconditionFailure("Cannot create Photo object.")
        }

        self.id = id
        self.data = data
        self.image = image
    }

    public init(id: UUID = UUID(), image: UIImage) {
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

extension Array where Element == UIImage {
    public func asPhotos() -> [Photo] {
        compactMap { $0.jpegData(compressionQuality: 1) }.map { .init(data: $0) }
    }
}
