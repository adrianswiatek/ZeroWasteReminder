@testable import ZeroWasteReminder
import Combine

internal final class StatusNotifierDummy: StatusNotifier {
    internal var remoteStatus: AnyPublisher<RemoteStatus, Never> =
        Just(.connected).eraseToAnyPublisher()

    internal var notificationStatus: AnyPublisher<NotificationConsentStatus, Never> =
        Just(.authorized).eraseToAnyPublisher()

    internal func refresh() {}
}
