import Combine
import UIKit

public final class RemoteNotificationHandler {
    private let eventDispatcher: EventDispatcher
    private let eventBuilders: [Category: ([AnyHashable: Any]) -> AppEventBuilder]

    public init(eventDispatcher: EventDispatcher) {
        self.eventDispatcher = eventDispatcher
        self.eventBuilders = [.item: ItemAppEventBuilder.init, .list: ListAppEventBuilder.init]
    }

    public func received(with userInfo: [AnyHashable: Any]) {
        guard let category = Category(from: userInfo) else { return }

        eventBuilders[category]?(userInfo).build().map {
            eventDispatcher.dispatch($0)
        }
    }
}

private protocol AppEventBuilder {
    func build() -> AppEvent?
}

private struct ListAppEventBuilder: AppEventBuilder {
    private let userInfo: [AnyHashable: Any]
    private let eventBuilders: [Action: (Id<List>) -> AppEvent]

    internal init(from userInfo: [AnyHashable: Any]) {
        self.userInfo = userInfo
        self.eventBuilders = [
            .add: ListRemotelyAdded.init,
            .remove: ListRemotelyRemoved.init,
            .update: ListRemotelyUpdated.init
        ]
    }

    internal func build() -> AppEvent? {
        guard let action = Action(from: userInfo) else { return nil }
        guard let buildEvent = eventBuilders[action] else { return nil }

        let ck = userInfo["ck"] as? [AnyHashable: Any]
        let qry = ck?["qry"] as? [AnyHashable: Any]
        let rid = qry?["rid"] as? String

        return rid.map { Id<List>.fromString($0) }.map { buildEvent($0) }
    }
}

private struct ItemAppEventBuilder: AppEventBuilder {
    private let userInfo: [AnyHashable: Any]
    private let eventBuilders: [Action: (Id<Item>, Id<List>) -> AppEvent]

    internal init(from userInfo: [AnyHashable: Any]) {
        self.userInfo = userInfo
        self.eventBuilders = [
            .add: ItemRemotelyAdded.init,
            .remove: ItemRemotelyRemoved.init,
            .update: ItemRemotelyUpdated.init
        ]
    }

    internal func build() -> AppEvent? {
        guard let action = Action(from: userInfo) else { return nil }
        guard let buildEvent = eventBuilders[action] else { return nil }

        let ck = userInfo["ck"] as? [AnyHashable: Any]
        let qry = ck?["qry"] as? [AnyHashable: Any]

        let rid = qry?["rid"] as? String
        guard let itemId: Id<Item> = rid.flatMap({ .fromString($0) }) else { return nil }

        let listId: Id<List> = .fromUuid(.empty)

        return buildEvent(itemId, listId)
    }
}

private enum Category {
    case item, list

    internal init?(from value: String) {
        switch value {
        case "Item": self = .item
        case "List": self = .list
        default: return nil
        }
    }

    internal init?(from userInfo: [AnyHashable: Any]) {
        let aps = userInfo["aps"] as? [AnyHashable: Any]

        guard let category = aps?["category"] as? String else {
            return nil
        }

        self.init(from: category)
    }
}

private enum Action {
    case add, update, remove

    internal init?(from value: Int) {
        switch value {
        case 1: self = .add
        case 2: self = .update
        case 3: self = .remove
        default: return nil
        }
    }

    internal init?(from userInfo: [AnyHashable: Any]) {
        let ck = userInfo["ck"] as? [AnyHashable: Any]
        let qry = ck?["qry"] as? [AnyHashable: Any]

        guard let fo = qry?["fo"] as? Int else {
            return nil
        }

        self.init(from: fo)
    }
}
