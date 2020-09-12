import Combine
import UIKit

public final class RemoteNotificationHandler {
    private let notificationCenter: NotificationCenter

    public init(notificationCenter: NotificationCenter) {
        self.notificationCenter = notificationCenter
    }

    public func received(with userInfo: [AnyHashable: Any]) {
        let payload = Payload(userInfo)

        switch payload.category {
        case "List":
            sendListNotification(from: payload)
        default:
            break
        }
    }

    private func sendListNotification(from payload: Payload) {
        guard let action = payload.action, let id = payload.recordId else {
            preconditionFailure("Unknown action or recordId.")
        }

        switch action {
        case .create:
            notificationCenter.post(name: .listCreateReceived, object: nil, userInfo: ["id": id])
        case .update:
            notificationCenter.post(name: .listUpdateReceived, object: nil, userInfo: ["id": id])
        case .remove:
            notificationCenter.post(name: .listRemoveReceived, object: nil, userInfo: ["id": id])
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
