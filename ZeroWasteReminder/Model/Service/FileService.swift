import Combine
import UIKit

public final class FileService {
    private let fileManager: FileManager

    public init(fileManager: FileManager) {
        self.fileManager = fileManager
    }

    public func trySaveData(_ data: Data) -> URL? {
        let url = newTemporaryFileUrl()

        do {
            try data.write(to: url)
            return url
        } catch {
            return nil
        }
    }

    public func saveTemporaryImage(_ image: UIImage) -> Future<URL, ServiceError> {
        Future { [weak self] promise in
            guard let url = self?.newTemporaryFileUrl() else { return }

            do {
                try image.jpegData(compressionQuality: 1)?.write(to: url)
                promise(.success(url))
            } catch {
                promise(.failure(.cannotWriteTo(url: url)))
            }
        }
    }

    public func removeTemporaryItems() -> Future<Void, ServiceError> {
        Future { [weak self] promise in
            guard let self = self else { return }

            do {
                let urls = try self.fileManager.contentsOfDirectory(
                    at: self.fileManager.temporaryDirectory,
                    includingPropertiesForKeys: nil,
                    options: []
                )
                try urls.forEach { try self.fileManager.removeItem(at: $0) }
            } catch {
                promise(.failure(.cannotRemoveItemAt(url: self.fileManager.temporaryDirectory)))
            }
        }
    }

    public func removeItem(at url: URL) -> Future<Void, ServiceError> {
        Future { [weak self] promise in
            do {
                try self?.fileManager.removeItem(at: url)
                promise(.success(()))
            } catch {
                promise(.failure(.cannotRemoveItemAt(url: url)))
            }
        }
    }

    private func newTemporaryFileUrl() -> URL {
        fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    }
}

extension FileService {
    public enum ServiceError: Error {
        case cannotWriteTo(url: URL)
        case cannotRemoveItemAt(url: URL)
    }
}
