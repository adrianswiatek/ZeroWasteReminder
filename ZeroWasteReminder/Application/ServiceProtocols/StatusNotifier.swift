import AVFoundation
import Combine
import Foundation
import Network
import NotificationCenter

public protocol StatusNotifier {
    var remoteStatus: AnyPublisher<RemoteStatus, Never> { get }
    var notificationStatus: AnyPublisher<NotificationConsentStatus, Never> { get }
    var cameraStatus: AnyPublisher<CameraConsentStatus, Never> { get }

    func refresh()
}

public enum CameraConsentStatus {
    case authorized
    case denied
    case notDetermined

    public static func from(_ authorizationStatus: AVAuthorizationStatus) -> CameraConsentStatus {
        switch authorizationStatus {
        case .notDetermined: return .notDetermined
        case .restricted, .denied: return .denied
        case .authorized: return .authorized
        @unknown default: preconditionFailure("Unknown authorization status.")
        }
    }
}

public enum NotificationConsentStatus {
    case authorized
    case denied

    public static func from(_ authorizationStatus: UNAuthorizationStatus) -> NotificationConsentStatus {
        authorizationStatus == .authorized ? .authorized : .denied
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
