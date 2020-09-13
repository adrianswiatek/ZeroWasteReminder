import Combine
import UIKit

public final class RemoteNotificationHandler {
    private let eventDispatcher: EventDispatcher

    public init(eventDispatcher: EventDispatcher) {
        self.eventDispatcher = eventDispatcher
    }

    public func received(with userInfo: [AnyHashable: Any]) {
        Payload(userInfo).map { dispatchEvent(from: $0) }
    }

    private func dispatchEvent(from payload: Payload) {
        switch payload.category {
        case .item: dispatchItemEvent(from: payload)
        case .list: dispatchListEvent(from: payload)
        }
    }

    private func dispatchItemEvent(from payload: Payload) {
        switch payload.action {
        case .add: eventDispatcher.dispatch(ItemRemotelyAdded(.fromUuid(payload.uuid)))
        case .remove: eventDispatcher.dispatch(ItemRemotelyRemoved(.fromUuid(payload.uuid)))
        case .update: eventDispatcher.dispatch(ItemRemotelyUpdated(.fromUuid(payload.uuid)))
        }
    }

    private func dispatchListEvent(from payload: Payload) {
        switch payload.action {
        case .add: eventDispatcher.dispatch(ListRemotelyAdded(.fromUuid(payload.uuid)))
        case .remove: eventDispatcher.dispatch(ListRemotelyRemoved(.fromUuid(payload.uuid)))
        case .update: eventDispatcher.dispatch(ListRemotelyUpdated(.fromUuid(payload.uuid)))
        }
    }
}

private extension RemoteNotificationHandler {
    struct Payload {
        let category: Category
        let action: Action
        let uuid: UUID

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
            guard let uuid = rid.flatMap({ UUID(uuidString: $0) }) else { return nil }
            self.uuid = uuid
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
