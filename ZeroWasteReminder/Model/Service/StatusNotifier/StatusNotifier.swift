import Combine
import Foundation
import Network

public protocol StatusNotifier {
    var remoteStatus: AnyPublisher<RemoteStatus, Never> { get }
}

public enum RemoteStatus: Equatable {
    case connected
    case notConnected(_ reason: Reason)
    case notDetermined
}

extension RemoteStatus {
    public enum Reason {
        case badInternetConnection
        case noInternetConnection
        case remoteAccountNotFound
    }
}
