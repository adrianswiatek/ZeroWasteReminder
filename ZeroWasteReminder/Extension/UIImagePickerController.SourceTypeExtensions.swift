import UIKit

public extension UIImagePickerController.SourceType {
    static func fromPhotoCaptureTarget(_ target: PhotoCaptureTarget) -> Self {
        switch target {
        case .camera: return .camera
        case .photoLibrary: return .photoLibrary
        }
    }
}
