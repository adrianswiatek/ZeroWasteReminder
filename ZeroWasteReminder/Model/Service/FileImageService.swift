import Combine
import UIKit

public final class FileService {
    private let fileManager: FileManager

    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    public func saveToTemporaryDirectory(_ data: Data, withName name: String) -> Future<URL?, FileImageServiceError> {
        let url = fileManager.temporaryDirectory.appendingPathComponent(name)

        return Future { promise in
            do {
                try data.write(to: url)
                promise(.success(url))
            } catch {
                promise(.failure(FileImageServiceError.cannotWriteTo(url: url)))
            }
        }
    }

    public func removeItemAt(url: URL) -> Future<Void, FileImageServiceError> {
        Future { [weak self] promise in
            do {
                try self?.fileManager.removeItem(at: url)
                promise(.success(()))
            } catch {
                promise(.failure(.cannotRemoveItemAt(url: url)))
            }
        }
    }
}

extension FileService {
    public enum FileImageServiceError: Error {
        case cannotWriteTo(url: URL)
        case cannotRemoveItemAt(url: URL)
    }
}
