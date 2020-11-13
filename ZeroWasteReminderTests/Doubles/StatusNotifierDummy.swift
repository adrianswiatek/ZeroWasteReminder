@testable import ZeroWasteReminder
import Combine

internal final class StatusNotifierDummy: StatusNotifier {
    internal let remoteStatus: AnyPublisher<RemoteStatus, Never> =
        Just(.connected).eraseToAnyPublisher()

    internal let notificationStatus: AnyPublisher<NotificationConsentStatus, Never> =
        Just(.authorized).eraseToAnyPublisher()

    internal let cameraStatus: AnyPublisher<CameraConsentStatus, Never> =
        Just(.authorized).eraseToAnyPublisher()

    internal func refresh() {}
}
