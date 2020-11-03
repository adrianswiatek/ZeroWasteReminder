import Combine
import Foundation
import Network
import NotificationCenter

public protocol StatusNotifier {
    var remoteStatus: AnyPublisher<RemoteStatus, Never> { get }
    var notificationStatus: AnyPublisher<NotificationConsentStatus, Never> { get }
}

public enum NotificationConsentStatus {
    case authorized
    case unauthorized

    public static func from(_ authorizationStatus: UNAuthorizationStatus) -> NotificationConsentStatus {
        authorizationStatus == .authorized ? .authorized : .unauthorized
    }
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
