import Combine

public final class AllAcceptedStatusNotifier: StatusNotifier {
    public var remoteStatus: AnyPublisher<RemoteStatus, Never> {
        Just(.connected).eraseToAnyPublisher()
    }

    public var notificationStatus: AnyPublisher<NotificationConsentStatus, Never> {
        Just(.authorized).eraseToAnyPublisher()
    }

    public var cameraStatus: AnyPublisher<CameraConsentStatus, Never> {
        Just(.authorized).eraseToAnyPublisher()
    }

    public func refresh() {}
}
