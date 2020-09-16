public protocol RemoteEventBuilder {
    func build() -> AppEvent?
}

public struct ListRemoteEventBuilder: RemoteEventBuilder {
    private let userInfo: [AnyHashable: Any]
    private let eventBuilders: [RemoteNotification.Action: (Id<List>) -> AppEvent]

    public init(from userInfo: [AnyHashable: Any]) {
        self.userInfo = userInfo
        self.eventBuilders = [
            .add: ListRemotelyAdded.init,
            .remove: ListRemotelyRemoved.init,
            .update: ListRemotelyUpdated.init
        ]
    }

    public func build() -> AppEvent? {
        guard let action = RemoteNotification.Action(from: userInfo) else { return nil }
        guard let buildEvent = eventBuilders[action] else { return nil }

        let ck = userInfo["ck"] as? [AnyHashable: Any]
        let qry = ck?["qry"] as? [AnyHashable: Any]
        let rid = qry?["rid"] as? String

        return rid.map { Id<List>.fromString($0) }.map { buildEvent($0) }
    }
}

public struct ItemRemoteEventBuilder: RemoteEventBuilder {
    private let userInfo: [AnyHashable: Any]
    private let eventBuilders: [RemoteNotification.Action: (Id<Item>, Id<List>) -> AppEvent]

    public init(from userInfo: [AnyHashable: Any]) {
        self.userInfo = userInfo
        self.eventBuilders = [
            .add: ItemRemotelyAdded.init,
            .remove: ItemRemotelyRemoved.init,
            .update: ItemRemotelyUpdated.init
        ]
    }

    public func build() -> AppEvent? {
        guard let action = RemoteNotification.Action(from: userInfo) else { return nil }
        guard let buildEvent = eventBuilders[action] else { return nil }

        let ck = userInfo["ck"] as? [AnyHashable: Any]
        let qry = ck?["qry"] as? [AnyHashable: Any]

        let rid = qry?["rid"] as? String
        guard let itemId: Id<Item> = rid.flatMap({ .fromString($0) }) else { return nil }

        let listId: Id<List> = .fromUuid(.empty)

        return buildEvent(itemId, listId)
    }
}
