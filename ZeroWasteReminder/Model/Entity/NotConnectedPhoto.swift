import UIKit

public struct NotConnectedPhoto: Hashable {
    private let data: Data

    public init(image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 1) else {
            preconditionFailure("Cannot create Photo object.")
        }

        self.data = data
    }

    public func asData() -> Data {
        data
    }
}
