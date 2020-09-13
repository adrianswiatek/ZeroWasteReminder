import Combine
import UIKit

public final class RemoteNotificationHandler {
    private let notificationCenter: NotificationCenter

    private let mappedItemNotifications: [Action: Notification.Name]
    private let mappedListNotifications: [Action: Notification.Name]

    public init(notificationCenter: NotificationCenter) {
        self.notificationCenter = notificationCenter

        self.mappedItemNotifications = [
            .create: .listCreateReceived,
            .remove: .listRemoveReceived,
            .update: .listUpdateReceived
        ]

        self.mappedListNotifications = [
            .create: .listCreateReceived,
            .remove: .listRemoveReceived,
            .update: .listUpdateReceived
        ]
    }

    public func received(with userInfo: [AnyHashable: Any]) {
        let payload = Payload(userInfo)

        guard let name = notificationName(from: payload) else {
            preconditionFailure("Unknown notification name.")
        }

        guard let id = payload.recordId else {
            preconditionFailure("Unknown recordId.")
        }

        notificationCenter.post(name: name, object: nil, userInfo: ["id": id])
    }

    private func notificationName(from payload: Payload) -> Notification.Name? {
        guard let action = payload.action else {
            preconditionFailure("Unknown action.")
        }

        switch payload.category {
        case "Item": return mappedItemNotifications[action]
        case "List": return mappedListNotifications[action]
        default: preconditionFailure("Unknown category.")
        }
    }
}

private extension RemoteNotificationHandler {
    struct Payload {
        let category: String?
        let action: Action?
        let recordId: UUID?

        init(_ userInfo: [AnyHashable: Any]) {
            let aps = userInfo["aps"] as? [AnyHashable: Any]
            category = aps?["category"] as? String

            let ck = userInfo["ck"] as? [AnyHashable: Any]
            let qry = ck?["qry"] as? [AnyHashable: Any]

            let fo = qry?["fo"] as? Int
            action = fo.flatMap { Action($0) }

            let rid = qry?["rid"] as? String
            recordId = rid.flatMap { UUID(uuidString: $0) }
        }
    }

    enum Action {
        case create, update, remove

        public init?(_ value: Int) {
            switch value {
            case 1: self = .create
            case 2: self = .update
            case 3: self = .remove
            default: return nil
            }
        }
    }
}
