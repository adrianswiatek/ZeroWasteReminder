import Combine
import UIKit

public final class RemoteNotificationHandler {
    private let notificationCenter: NotificationCenter

    private let mappedItemNotifications: [Action: Notification.Name]
    private let mappedListNotifications: [Action: Notification.Name]

    public init(notificationCenter: NotificationCenter) {
        self.notificationCenter = notificationCenter

        self.mappedItemNotifications = [
            .add: .itemAddReceived,
            .remove: .itemRemoveReceived,
            .update: .itemUpdateReceived
        ]

        self.mappedListNotifications = [
            .add: .listAddReceived,
            .remove: .listRemoveReceived,
            .update: .listUpdateReceived
        ]
    }

    public func received(with userInfo: [AnyHashable: Any]) {
        guard let payload = Payload(userInfo) else {
            assertionFailure("Payload is expected to be initialized.")
            return
        }

        notificationName(from: payload).map {
            notificationCenter.post(name: $0, object: nil, userInfo: ["id": payload.recordId])
        }
    }

    private func notificationName(from payload: Payload) -> Notification.Name? {
        switch payload.category {
        case .item: return mappedItemNotifications[payload.action]
        case .list: return mappedListNotifications[payload.action]
        }
    }
}

private extension RemoteNotificationHandler {
    struct Payload {
        let category: Category
        let action: Action
        let recordId: UUID

        init?(_ userInfo: [AnyHashable: Any]) {
            let aps = userInfo["aps"] as? [AnyHashable: Any]
            guard let category = (aps?["category"] as? String).flatMap({ Category($0) }) else { return nil }
            self.category = category

            let ck = userInfo["ck"] as? [AnyHashable: Any]
            let qry = ck?["qry"] as? [AnyHashable: Any]

            let fo = qry?["fo"] as? Int
            guard let action = fo.flatMap({ Action($0) }) else { return nil }
            self.action = action

            let rid = qry?["rid"] as? String
            guard let recordId = rid.flatMap({ UUID(uuidString: $0) }) else { return nil }
            self.recordId = recordId
        }
    }

    enum Category {
        case item, list

        public init?(_ value: String) {
            switch value {
            case "Item": self = .item
            case "List": self = .list
            default: return nil
            }
        }
    }

    enum Action {
        case add, update, remove

        public init?(_ value: Int) {
            switch value {
            case 1: self = .add
            case 2: self = .update
            case 3: self = .remove
            default: return nil
            }
        }
    }
}
