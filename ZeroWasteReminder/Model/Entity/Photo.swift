import UIKit

public struct Photo: Hashable {
    public let data: Data

    public static func from(_ image: UIImage) -> Photo {
        guard let imageData = image.pngData() else {
            preconditionFailure("Cannot create PNG data.")
        }

        return Photo(data: imageData)
    }
}

extension Array where Element == UIImage {
    public func asPhotos() -> [Photo] {
        compactMap { $0.pngData() }.map { Photo(data: $0) }
    }
}
