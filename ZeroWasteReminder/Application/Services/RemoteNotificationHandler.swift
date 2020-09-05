import Combine
import UIKit

public final class RemoteNotificationHandler {
    private let notificationCenter: NotificationCenter

    public init(notificationCenter: NotificationCenter) {
        self.notificationCenter = notificationCenter
    }

    public func received(with userInfo: [AnyHashable: Any]) {
        guard Aps(userInfo)?.category == "Item" else { return }
        NotificationCenter.default.post(.init(name: .itemUpdateReceived))
    }
}

private extension RemoteNotificationHandler {
    struct Aps {
        let category: String?

        init?(_ userInfo: [AnyHashable: Any]) {
            let aps = userInfo["aps"] as? [AnyHashable: Any]
            category = aps?["category"] as? String
        }
    }
}
