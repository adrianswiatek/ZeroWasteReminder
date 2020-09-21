import Foundation

public protocol RemoteEventBuilder {
    func build() -> AppEvent?
}

public struct ListRemoteEventBuilder: RemoteEventBuilder {
    private let userInfo: [AnyHashable: Any]
    private let eventBuilders: [RemoteNotification.Action: (Id<List>) -> AppEvent]

    public init(from userInfo: [AnyHashable: Any]) {
        self.userInfo = userInfo
        self.eventBuilders = [
            .add: ListAddedReceived.init,
            .remove: ListRemovedReceived.init,
            .update: ListUpdatedReceived.init
        ]
    }

    public func build() -> AppEvent? {
        guard
            let action = RemoteNotification.Action(from: userInfo),
            let buildEvent = eventBuilders[action],
            let recordId = RemoteNotification.RecordId(from: userInfo)
        else { return nil }

        return buildEvent(.fromUuid(recordId.uuid))
    }
}

public struct ItemRemoteEventBuilder: RemoteEventBuilder {
    private let userInfo: [AnyHashable: Any]
    private let eventBuilders: [RemoteNotification.Action: (Id<Item>, Id<List>) -> AppEvent]

    public init(from userInfo: [AnyHashable: Any]) {
        self.userInfo = userInfo
        self.eventBuilders = [
            .add: ItemAddedReceived.init,
            .remove: ItemRemovedReceived.init,
            .update: ItemUpdatedReceived.init
        ]
    }

    public func build() -> AppEvent? {
        guard
            let action = RemoteNotification.Action(from: userInfo),
            let buildEvent = eventBuilders[action],
            let recordId = RemoteNotification.RecordId(from: userInfo),
            let listReference = RemoteNotification.ListReference(from: userInfo)
        else { return nil }

        return buildEvent(.fromUuid(recordId.uuid), .fromUuid(listReference.uuid))
    }
}

public struct PhotoRemoteEventBuilder: RemoteEventBuilder {
    private let userInfo: [AnyHashable: Any]
    private let eventBuilders: [RemoteNotification.Action: (Id<Photo>, Id<Item>) -> AppEvent]

    public init(from userInfo: [AnyHashable: Any]) {
        self.userInfo = userInfo
        self.eventBuilders = [.add: PhotoAddedReceived.init, .remove: PhotoRemovedReceived.init]
    }

    public func build() -> AppEvent? {
        guard
            let action = RemoteNotification.Action(from: userInfo),
            let buildEvent = eventBuilders[action],
            let recordId = RemoteNotification.RecordId(from: userInfo),
            let itemReference = RemoteNotification.ItemReference(from: userInfo)
        else { return nil }

        return buildEvent(.fromUuid(recordId.uuid), .fromUuid(itemReference.uuid))
    }
}

enum RemoteNotification {
    public struct RecordId {
        public let uuid: UUID

        public init?(from userInfo: [AnyHashable: Any]) {
            guard
                let ck = userInfo["ck"] as? [AnyHashable: Any],
                let qry = ck["qry"] as? [AnyHashable: Any],
                let rid = qry["rid"] as? String,
                let uuid = UUID(uuidString: rid)
            else { return nil }

            self.uuid = uuid
        }
    }

    public struct ItemReference {
        public let uuid: UUID

        public init?(from userInfo: [AnyHashable: Any]) {
            guard
                let ck = userInfo["ck"] as? [AnyHashable: Any],
                let qry = ck["qry"] as? [AnyHashable: Any],
                let af = qry["af"] as? [AnyHashable: Any],
                let itemReference = af["itemReference"] as? String,
                let uuid = UUID(uuidString: itemReference)
            else { return nil }

            self.uuid = uuid
        }
    }

    public struct ListReference {
        public let uuid: UUID

        public init?(from userInfo: [AnyHashable: Any]) {
            guard
                let ck = userInfo["ck"] as? [AnyHashable: Any],
                let qry = ck["qry"] as? [AnyHashable: Any],
                let af = qry["af"] as? [AnyHashable: Any],
                let listReference = af["listReference"] as? String,
                let uuid = UUID(uuidString: listReference)
            else { return nil }

            self.uuid = uuid
        }
    }

    public enum Category {
        case item, list, photo

        public init?(from value: String) {
            switch value {
            case "Item": self = .item
            case "List": self = .list
            case "Photo": self = .photo
            default: return nil
            }
        }

        public init?(from userInfo: [AnyHashable: Any]) {
            let aps = userInfo["aps"] as? [AnyHashable: Any]

            guard let category = aps?["category"] as? String else {
                return nil
            }

            self.init(from: category)
        }
    }

    public enum Action {
        case add, update, remove

        public init?(from value: Int) {
            switch value {
            case 1: self = .add
            case 2: self = .update
            case 3: self = .remove
            default: return nil
            }
        }

        public init?(from userInfo: [AnyHashable: Any]) {
            guard
                let ck = userInfo["ck"] as? [AnyHashable: Any],
                let qry = ck["qry"] as? [AnyHashable: Any],
                let fo = qry["fo"] as? Int
            else { return nil }

            self.init(from: fo)
        }
    }
}
