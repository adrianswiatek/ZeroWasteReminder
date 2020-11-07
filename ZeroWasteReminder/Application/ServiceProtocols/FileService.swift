import Combine
import Foundation
import UIKit

public protocol FileService {
    func trySaveData(_ data: Data) -> URL?
    func saveTemporaryImage(_ image: UIImage) -> Future<URL, FileServiceError>
    func removeTemporaryItems() -> Future<Void, FileServiceError>
    func removeItem(at url: URL) -> Future<Void, FileServiceError>
}

public enum FileServiceError: Error {
    case cannotWriteTo(url: URL)
    case cannotRemoveItemAt(url: URL)
}
